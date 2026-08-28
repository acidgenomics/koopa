"""AWS CLI wrapper functions.

Converted from Bash functions: aws-s3-sync, aws-s3-ls, aws-s3-cp-regex,
aws-s3-find, aws-s3-list-large-files, aws-ecr-login-private,
aws-ecr-login-public, aws-ec2-list-running-instances,
aws-batch-list-jobs, etc.
"""

import json
import os
import re
import subprocess
from pathlib import Path

# ---------------------------------------------------------------------------
# .env loader and account-scoped bucket helpers
# ---------------------------------------------------------------------------


def _parse_dotenv(env_path: Path | None = None) -> dict[str, str]:
    """Parse '<koopa-root>/.env' into a dict, without touching 'os.environ'.

    *env_path* is exposed for tests; production callers always use the default.
    """
    if env_path is None:
        env_path = Path(__file__).parents[4] / ".env"
    if not env_path.is_file():
        return {}
    parsed: dict[str, str] = {}
    with open(env_path) as fh:
        for raw in fh:
            stripped = raw.strip()
            if not stripped or stripped.startswith("#") or "=" not in stripped:
                continue
            key, _, value = stripped.partition("=")
            key = key.strip()
            if key:
                parsed[key] = value.strip()
    return parsed


def dotenv_value(key: str) -> str:
    """Return *key* from 'os.environ', else from '<koopa-root>/.env', else ''.

    Never copies any other key into 'os.environ'. The whole point of
    'koopa.system.revert_direnv_env' is that a project-scoped credential must
    not reach koopa's subprocesses; a helper that loaded the entire file to
    answer one lookup put every '.env' secret straight back.
    """
    value = os.environ.get(key, "")
    if value:
        return value
    return _parse_dotenv().get(key, "")


def aws_account_id() -> str:
    """Return the AWS account ID from AWS_ACCOUNT_ID env var, raising if absent."""
    account_id = dotenv_value("AWS_ACCOUNT_ID")
    if not account_id:
        msg = "AWS_ACCOUNT_ID must be set (in environment or <koopa-root>/.env)."
        raise RuntimeError(msg)
    return account_id


def koopa_s3_bucket(role: str) -> str:
    """Return a private koopa S3 bucket name for the given role.

    Bucket naming convention: <role>-<account-id>-us-east-1-an.
    Examples: koopa_s3_bucket('r'), koopa_s3_bucket('artifacts').
    """
    return f"{role}-{aws_account_id()}-us-east-1-an"


# ---------------------------------------------------------------------------


class _AwsError(subprocess.CalledProcessError):
    """CalledProcessError that includes AWS CLI stderr in its message.

    Subclasses rather than replaces CalledProcessError so existing handlers
    (e.g. the s3 rm retry in cli_develop) keep catching it and reading .stderr.
    """

    def __str__(self) -> str:
        base = f"aws command failed (exit {self.returncode}): {' '.join(self.cmd[1:])}"
        stderr = (self.stderr or "").strip()
        if stderr:
            return f"{base}\n{stderr}"
        return base


# Force the AWS CLI to ignore every ambient credential source and fall
# through to the EC2 instance profile (IMDS). A '[default]' block in
# '~/.aws/credentials', or an exported 'AWS_PROFILE', otherwise outranks
# IMDS. On a host whose own AWS account has no named profile at all, that
# makes a self-directed 'stop-instances' fail with
# 'InvalidInstanceID.NotFound' rather than a permission error.
#
# 'AWS_PROFILE' must be dropped even though credentials are not injected
# here: botocore removes its env credential provider entirely when a profile
# is set explicitly, and a named profile cannot resolve once the config file
# is '/dev/null'.
_INSTANCE_IDENTITY_ENV: dict[str, str | None] = {
    "AWS_CONFIG_FILE": os.devnull,
    "AWS_SHARED_CREDENTIALS_FILE": os.devnull,
    "AWS_PROFILE": None,
    "AWS_DEFAULT_PROFILE": None,
    "AWS_ACCESS_KEY_ID": None,
    "AWS_SECRET_ACCESS_KEY": None,
    "AWS_SESSION_TOKEN": None,
    "AWS_EC2_METADATA_DISABLED": None,
}


def _aws(
    *args: str,
    capture: bool = True,
    timeout: int = 300,
    env: dict[str, str | None] | None = None,
) -> subprocess.CompletedProcess:
    """Run an AWS CLI command.

    *env* overrides the inherited environment. A value of 'None' removes
    that variable instead of setting it.
    """
    cmd = ["aws", *args]
    run_env = os.environ.copy()
    run_env["AWS_PAGER"] = ""
    for key, value in (env or {}).items():
        if value is None:
            run_env.pop(key, None)
        else:
            run_env[key] = value
    try:
        return subprocess.run(
            cmd, capture_output=capture, text=True, check=True, timeout=timeout, env=run_env
        )
    except subprocess.CalledProcessError as exc:
        raise _AwsError(exc.returncode, exc.cmd, exc.output, exc.stderr) from exc


def aws_s3_sync(
    source: str,
    target: str,
    *,
    delete: bool = False,
    exclude: list[str] | None = None,
    include: list[str] | None = None,
    dryrun: bool = False,
    follow_symlinks: bool = False,
    size_only: bool = False,
    profile: str | None = None,
) -> None:
    """Sync files between local and S3 or between S3 buckets."""
    args = ["s3", "sync", source, target]
    if delete:
        args.append("--delete")
    if dryrun:
        args.append("--dryrun")
    if follow_symlinks:
        args.append("--follow-symlinks")
    if size_only:
        args.append("--size-only")
    if exclude:
        for pattern in exclude:
            args.extend(["--exclude", pattern])
    if include:
        for pattern in include:
            args.extend(["--include", pattern])
    if profile:
        args.extend(["--profile", profile])
    _aws(*args, capture=False)


def aws_s3_ls(
    path: str,
    *,
    recursive: bool = False,
    profile: str | None = None,
) -> str:
    """List S3 objects."""
    args = ["s3", "ls", path]
    if recursive:
        args.append("--recursive")
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    return result.stdout


def s3_object_exists(
    bucket: str,
    key: str,
    *,
    profile: str = "acidgenomics",
) -> bool:
    """Check whether an object exists in an S3 bucket via head-object."""
    result = subprocess.run(
        [
            "aws",
            "s3api",
            "head-object",
            "--bucket",
            bucket,
            "--key",
            key,
            "--profile",
            profile,
        ],
        capture_output=True,
        check=False,
    )
    return result.returncode == 0


def aws_s3_cp(
    source: str,
    target: str,
    *,
    recursive: bool = False,
    profile: str | None = None,
) -> None:
    """Copy files to/from S3."""
    args = ["s3", "cp", source, target]
    if recursive:
        args.append("--recursive")
    if profile:
        args.extend(["--profile", profile])
    _aws(*args, capture=False)


def aws_s3_cp_regex(
    source_dir: str,
    target_dir: str,
    pattern: str,
    *,
    profile: str | None = None,
) -> None:
    """Copy S3 files matching a regex pattern."""
    args = [
        "s3",
        "cp",
        source_dir,
        target_dir,
        "--recursive",
        "--exclude",
        "*",
        "--include",
        pattern,
    ]
    if profile:
        args.extend(["--profile", profile])
    _aws(*args, capture=False)


def aws_s3_find(
    bucket: str,
    *,
    prefix: str = "",
    pattern: str = "",
    profile: str | None = None,
) -> list[str]:
    """Find files in S3 matching a pattern."""
    args = ["s3api", "list-objects-v2", "--bucket", bucket]
    if prefix:
        args.extend(["--prefix", prefix])
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    data = json.loads(result.stdout)
    keys = [obj["Key"] for obj in data.get("Contents", [])]
    if pattern:
        rx = re.compile(pattern)
        keys = [k for k in keys if rx.search(k)]
    return keys


def aws_s3_list_large_files(
    bucket: str,
    *,
    min_size_mb: float = 100,
    prefix: str = "",
    profile: str | None = None,
) -> list[tuple[str, float]]:
    """List large files in an S3 bucket."""
    args = ["s3api", "list-objects-v2", "--bucket", bucket]
    if prefix:
        args.extend(["--prefix", prefix])
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    data = json.loads(result.stdout)
    large = []
    min_bytes = min_size_mb * 1024 * 1024
    for obj in data.get("Contents", []):
        size = obj.get("Size", 0)
        if size >= min_bytes:
            large.append((obj["Key"], size / (1024 * 1024)))
    large.sort(key=lambda x: x[1], reverse=True)
    return large


def aws_s3_delete_versioned_objects(
    bucket: str,
    *,
    prefix: str = "",
    glacier: bool = False,
    profile: str | None = None,
) -> int:
    """Delete versioned objects (optionally only Glacier storage class)."""
    args = ["s3api", "list-object-versions", "--bucket", bucket]
    if prefix:
        args.extend(["--prefix", prefix])
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    data = json.loads(result.stdout)
    deleted = 0
    for version in data.get("Versions", []):
        if glacier and version.get("StorageClass") != "GLACIER":
            continue
        del_args = [
            "s3api",
            "delete-object",
            "--bucket",
            bucket,
            "--key",
            version["Key"],
            "--version-id",
            version["VersionId"],
        ]
        if profile:
            del_args.extend(["--profile", profile])
        _aws(*del_args)
        deleted += 1
    for marker in data.get("DeleteMarkers", []):
        del_args = [
            "s3api",
            "delete-object",
            "--bucket",
            bucket,
            "--key",
            marker["Key"],
            "--version-id",
            marker["VersionId"],
        ]
        if profile:
            del_args.extend(["--profile", profile])
        _aws(*del_args)
        deleted += 1
    return deleted


def aws_s3_dot_clean(
    path: str,
    *,
    dryrun: bool = False,
    profile: str | None = None,
) -> list[str]:
    """Remove dot files (macOS cruft) from an S3 path."""
    ls_args = ["s3", "ls", path, "--recursive"]
    if profile:
        ls_args.extend(["--profile", profile])
    result = _aws(*ls_args)
    removed: list[str] = []
    for line in result.stdout.strip().splitlines():
        parts = line.split(maxsplit=3)
        if len(parts) < 4:
            continue
        key = parts[3]
        name = key.rsplit("/", maxsplit=1)[-1]
        if name.startswith("._") or name == ".DS_Store":
            full = path.rstrip("/") + "/" + key if not path.endswith(key) else path
            if not dryrun:
                rm_args = ["s3", "rm", full]
                if profile:
                    rm_args.extend(["--profile", profile])
                _aws(*rm_args, capture=False)
            removed.append(key)
    return removed


def aws_s3_mv_to_parent(
    path: str,
    *,
    dryrun: bool = False,
    profile: str | None = None,
) -> None:
    """Move all objects in an S3 subdirectory up to the parent."""
    args = ["s3", "mv", path, path.rsplit("/", maxsplit=2)[0] + "/", "--recursive"]
    if dryrun:
        args.append("--dryrun")
    if profile:
        args.extend(["--profile", profile])
    _aws(*args, capture=False)


def aws_s3_bucket(name: str | None = None) -> str:
    """Get S3 bucket URI."""
    if name is None:
        result = _aws("s3", "ls")
        lines = result.stdout.strip().splitlines()
        if lines:
            return lines[0].split()[-1]
        return ""
    return f"s3://{name}"


def aws_ec2_map_instance_ids_to_names(
    *,
    profile: str | None = None,
) -> list[dict]:
    """Map EC2 instance IDs to their Name tags."""
    args = [
        "ec2",
        "describe-instances",
        "--query",
        "Reservations[].Instances[].{Id:InstanceId,Name:Tags[?Key==`Name`].Value|[0]}",
        "--output",
        "json",
    ]
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    return json.loads(result.stdout)


_IMDS_BASE = "http://169.254.169.254/latest"


def _imds_get(path: str, *, timeout: int = 2) -> str:
    """Fetch *path* from the EC2 instance metadata service, using IMDSv2."""
    import urllib.request

    token_req = urllib.request.Request(
        f"{_IMDS_BASE}/api/token",
        method="PUT",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
    )
    with urllib.request.urlopen(token_req, timeout=timeout) as resp:
        token = resp.read().decode()
    req = urllib.request.Request(
        f"{_IMDS_BASE}/{path.lstrip('/')}",
        headers={"X-aws-ec2-metadata-token": token},
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read().decode().strip()


def aws_ec2_instance_id() -> str:
    """Get the current EC2 instance ID via instance metadata."""
    return _imds_get("meta-data/instance-id")


def aws_ec2_region() -> str:
    """Get the current EC2 instance's region via instance metadata."""
    return _imds_get("meta-data/placement/region")


def aws_ec2_stop(
    instance_ids: list[str],
    *,
    profile: str | None = None,
    region: str | None = None,
    instance_identity: bool = False,
) -> None:
    """Stop EC2 instances.

    Set *instance_identity* to stop the host this call runs on. The AWS CLI
    then ignores every ambient credential source and uses the instance
    profile from IMDS. Pass *region* with it, because neutralizing the config
    file also drops that file's 'region' setting.
    """
    args = ["ec2", "stop-instances", "--instance-ids", *instance_ids]
    if region:
        args.extend(["--region", region])
    if profile:
        args.extend(["--profile", profile])
    _aws(*args, env=_INSTANCE_IDENTITY_ENV if instance_identity else None)
    print(f"Stopping: {', '.join(instance_ids)}")


def aws_ecr_login_private(
    region: str = "us-east-1",
    *,
    account_id: str | None = None,
    profile: str | None = None,
) -> None:
    """Login to private AWS ECR."""
    args = ["ecr", "get-login-password", "--region", region]
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    password = result.stdout.strip()
    if account_id is None:
        sts_result = _aws("sts", "get-caller-identity")
        sts_data = json.loads(sts_result.stdout)
        account_id = sts_data["Account"]
    registry = f"{account_id}.dkr.ecr.{region}.amazonaws.com"
    subprocess.run(
        ["docker", "login", "--username", "AWS", "--password-stdin", registry],
        input=password,
        text=True,
        check=True,
    )


def aws_ecr_login_public(region: str = "us-east-1") -> None:
    """Login to public AWS ECR."""
    result = _aws("ecr-public", "get-login-password", "--region", region)
    password = result.stdout.strip()
    subprocess.run(
        ["docker", "login", "--username", "AWS", "--password-stdin", "public.ecr.aws"],
        input=password,
        text=True,
        check=True,
    )


def aws_ec2_list_running_instances(
    *,
    profile: str | None = None,
) -> list[dict]:
    """List running EC2 instances."""
    args = [
        "ec2",
        "describe-instances",
        "--filters",
        "Name=instance-state-name,Values=running",
    ]
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    data = json.loads(result.stdout)
    instances = []
    for reservation in data.get("Reservations", []):
        for inst in reservation.get("Instances", []):
            name = ""
            for tag in inst.get("Tags", []):
                if tag["Key"] == "Name":
                    name = tag["Value"]
            instances.append(
                {
                    "id": inst["InstanceId"],
                    "type": inst["InstanceType"],
                    "state": inst["State"]["Name"],
                    "name": name,
                    "ip": inst.get("PublicIpAddress", ""),
                    "private_ip": inst.get("PrivateIpAddress", ""),
                }
            )
    return instances


def aws_batch_fetch_and_run(
    queue: str,
    job_definition: str,
    *,
    job_name: str = "fetch-and-run",
    command: list[str] | None = None,
    vcpus: int = 1,
    memory: int = 2048,
    profile: str | None = None,
) -> dict:
    """Submit an AWS Batch fetch-and-run job."""
    args = [
        "batch",
        "submit-job",
        "--job-name",
        job_name,
        "--job-queue",
        queue,
        "--job-definition",
        job_definition,
    ]
    overrides: dict = {
        "vcpus": vcpus,
        "memory": memory,
    }
    if command:
        overrides["command"] = command
    args.extend(["--container-overrides", json.dumps(overrides)])
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    return json.loads(result.stdout)


def aws_batch_list_jobs(
    queue: str,
    *,
    status: str = "RUNNING",
    profile: str | None = None,
) -> list[dict]:
    """List AWS Batch jobs."""
    args = [
        "batch",
        "list-jobs",
        "--job-queue",
        queue,
        "--job-status",
        status,
    ]
    if profile:
        args.extend(["--profile", profile])
    result = _aws(*args)
    data = json.loads(result.stdout)
    return data.get("jobSummaryList", [])
