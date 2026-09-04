"""Docker image management functions.

Converted from Bash functions in ``lang/bash/functions/docker/``.
"""

import os
import re
import subprocess
from datetime import UTC, datetime
from os.path import abspath, basename, expanduser, isdir, isfile, join
from pathlib import Path

from koopa.fs import list_subdirs

_ECR_PRIVATE_RE = re.compile(r"^\d+\.dkr\.ecr\.[a-z0-9-]+\.amazonaws\.com(/|$)")


def _docker(
    *args: str,
    check: bool = True,
    capture_output: bool = False,
    text: bool = False,
) -> subprocess.CompletedProcess:
    """Run a docker command.

    Parameters
    ----------
    *args : str
        Arguments to pass to the ``docker`` command.
    check : bool, optional
        Raise ``CalledProcessError`` if the command exits with a non-zero
        status.
    capture_output : bool, optional
        Capture stdout and stderr instead of inheriting the parent process
        streams.
    text : bool, optional
        Decode stdout and stderr as text instead of bytes.

    Returns
    -------
    subprocess.CompletedProcess
        The completed docker process, including its return code and any
        captured output.
    """
    import shutil

    docker = shutil.which("docker")
    if docker is None:
        msg = "docker is not installed."
        raise RuntimeError(msg)
    docker_bin = os.path.dirname(os.path.realpath(docker))
    env = os.environ.copy()
    path = env.get("PATH", "")
    if docker_bin not in path.split(os.pathsep):
        env["PATH"] = docker_bin + os.pathsep + path
    return subprocess.run(
        [docker, *args],
        check=check,
        env=env,
        capture_output=capture_output,
        text=text,
    )


def build(
    *,
    local: str,
    remote: str,
    memory: str = "",
    no_push: bool = False,
) -> None:
    """Build and push a multi-architecture Docker image using buildx.

    Parameters
    ----------
    local : str
        Path to the local directory containing the Dockerfile to build.
    remote : str
        Remote image URL to tag and push the build to.
    memory : str, optional
        Memory limit to pass to buildx (e.g. ``"4g"``); applied to both
        ``--memory`` and ``--memory-swap``.
    no_push : bool, optional
        Build the image without pushing it to the remote registry.
    """
    local = abspath(expanduser(local))
    if not isdir(local):
        msg = f"Local directory does not exist: '{local}'."
        raise FileNotFoundError(msg)
    dockerfile = join(local, "Dockerfile")
    if not isfile(dockerfile):
        msg = f"Dockerfile not found: '{dockerfile}'."
        raise FileNotFoundError(msg)
    push = not no_push
    if ":" not in remote:
        remote = remote + ":latest"
    if not re.match(r"^(.+)/(.+)/(.+):(.+)$", remote):
        msg = f"Invalid remote URL format: '{remote}'."
        raise ValueError(msg)
    remote_str = remote.replace(":", "/", 1)
    parts = remote_str.split("/")
    server = parts[0]
    image_name = "/".join(parts[:3])
    tag = parts[3] if len(parts) > 3 else "latest"
    if push:
        _authenticate(server)
    tags: list[str] = []
    tags_file = join(local, "tags.txt")
    if isfile(tags_file):
        tags.extend(
            line.strip() for line in Path(tags_file).read_text().splitlines() if line.strip()
        )
    if os.path.islink(local):
        tags.append(tag)
        local = os.path.realpath(local)
        tag = basename(local)
    date_tag = datetime.now(tz=UTC).strftime("%Y%m%d")
    tags.extend([tag, f"{tag}-{date_tag}"])
    tags = sorted(set(tags))
    platforms = ["linux/amd64"]
    platforms_file = join(local, "platforms.txt")
    if isfile(platforms_file):
        platforms = [
            line.strip() for line in Path(platforms_file).read_text().splitlines() if line.strip()
        ]
    build_args: list[str] = []
    for t in tags:
        build_args.append(f"--tag={image_name}:{t}")
    build_args.append(f"--platform={','.join(platforms)}")
    if memory:
        build_args.extend(
            [
                f"--memory={memory}",
                f"--memory-swap={memory}",
            ]
        )
    build_args.extend(["--no-cache", "--progress=auto", "--pull"])
    if push:
        build_args.append("--push")
    build_args.append(local)
    # Prune existing locally tagged images.
    result = _docker(
        "image",
        "ls",
        "--filter",
        f"reference={remote}",
        "--quiet",
        capture_output=True,
        text=True,
        check=False,
    )
    image_ids = [x for x in result.stdout.strip().splitlines() if x]
    if image_ids:
        _docker("image", "rm", "--force", *image_ids, check=False)
    print(f"Building '{remote}' Docker image.")
    build_name = basename(image_name)
    _docker("buildx", "rm", build_name, check=False, capture_output=True)
    _docker("buildx", "create", f"--name={build_name}", "--use", capture_output=True)
    try:
        _docker("buildx", "build", *build_args)
    finally:
        _docker("buildx", "rm", build_name, check=False, capture_output=True)
    _docker("image", "ls", "--filter", f"reference={remote}")
    if push:
        _docker("logout", server, check=False, capture_output=True)
    print(f"Build of '{remote}' was successful.")


def _authenticate(server: str) -> None:
    """Authenticate with a Docker registry.

    Parameters
    ----------
    server : str
        Registry hostname to authenticate against.
    """
    if _ECR_PRIVATE_RE.match(server):
        from koopa.aws import aws_ecr_login_private

        aws_ecr_login_private()
    elif server == "public.ecr.aws":
        from koopa.aws import aws_ecr_login_public

        aws_ecr_login_public()
    else:
        _docker("logout", server, check=False, capture_output=True)
        _docker("login", server)


def build_all_tags(local: str, remote: str) -> None:
    """Build all Docker tags from subdirectories.

    Parameters
    ----------
    local : str
        Path to the local directory whose subdirectories each represent a
        tag to build.
    remote : str
        Remote image URL (without tag) to build and push each subdirectory
        tag to.
    """
    local = abspath(expanduser(local))
    if not isdir(local):
        msg = f"Directory does not exist: '{local}'."
        raise FileNotFoundError(msg)
    tags = list_subdirs(
        path=local,
        recursive=False,
        sort=True,
        basename_only=True,
    )
    for tag in tags:
        local2 = join(local, tag)
        if not isdir(local2):
            continue
        remote2 = remote + ":" + tag
        build(local=local2, remote=remote2)


def ghcr_login() -> None:
    """Log in to GitHub Container Registry."""
    pat = os.environ.get("GHCR_PAT")
    user = os.environ.get("GHCR_USER")
    if not pat or not user:
        msg = "GHCR_PAT and GHCR_USER environment variables are required."
        raise RuntimeError(msg)
    subprocess.run(
        ["docker", "login", "ghcr.io", "-u", user, "--password-stdin"],
        input=pat,
        text=True,
        check=True,
    )


def ghcr_push(owner: str, image_name: str, version: str) -> None:
    """Push an image to GitHub Container Registry.

    Parameters
    ----------
    owner : str
        GitHub Container Registry owner (user or organization).
    image_name : str
        Name of the image to push.
    version : str
        Tag to push the image as.
    """
    url = f"ghcr.io/{owner}/{image_name}:{version}"
    ghcr_login()
    _docker("push", url)


def is_build_recent(*images: str, days: int = 7) -> bool:
    """Check if Docker images were built within N days.

    Parameters
    ----------
    *images : str
        Image references to check; each is pulled and inspected.
    days : int, optional
        Maximum age in days for a build to be considered recent.

    Returns
    -------
    bool
        True if every image was built within the given number of days.
    """
    seconds = days * 86400
    now = datetime.now(tz=UTC)
    for image in images:
        _docker("pull", image, capture_output=True)
        result = _docker(
            "inspect",
            "--format={{json .Created}}",
            image,
            capture_output=True,
            text=True,
        )
        created_str = result.stdout.strip().strip('"')
        match = re.search(
            r"(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})",
            created_str,
        )
        if match is None:
            return False
        dt_str = f"{match.group(1)} {match.group(2)} UTC"
        created = datetime.strptime(dt_str, "%Y-%m-%d %H:%M %Z").replace(
            tzinfo=UTC,
        )
        diff = (now - created).total_seconds()
        if diff > seconds:
            return False
    return True


def prune_all_images() -> None:
    """Prune all Docker images (nuclear option)."""
    print("Pruning Docker buildx.")
    _docker("buildx", "prune", "--all", "--force", "--verbose", check=False)
    print("Pruning Docker images.")
    _docker("system", "prune", "--all", "--force", check=False)
    _docker("images")


def prune_old_images() -> None:
    """Prune Docker images older than 3 months."""
    print("Pruning Docker images older than 3 months.")
    _docker(
        "image",
        "prune",
        "--all",
        "--filter",
        "until=2160h",
        "--force",
        check=False,
    )
    _docker("image", "prune", "--force", check=False)


def remove(*patterns: str) -> None:
    """Remove Docker images by pattern matching.

    Parameters
    ----------
    *patterns : str
        Regular expression patterns matched against ``docker images``
        output lines; matching images are removed.
    """
    for pattern in patterns:
        result = _docker(
            "images",
            capture_output=True,
            text=True,
            check=False,
        )
        image_ids: list[str] = []
        for line in result.stdout.splitlines():
            if re.search(pattern, line):
                parts = line.split()
                if len(parts) >= 3:
                    image_ids.append(parts[2])
        if image_ids:
            _docker("rmi", "--force", *image_ids, check=False)


def run(
    image: str,
    *,
    arm: bool = False,
    x86: bool = False,
    bash: bool = False,
    bind: bool = False,
) -> None:
    """Run a Docker image interactively.

    Parameters
    ----------
    image : str
        Image reference to pull and run.
    arm : bool, optional
        Run the image under the ``linux/arm64`` platform.
    x86 : bool, optional
        Run the image under the ``linux/amd64`` platform.
    bash : bool, optional
        Launch an interactive login bash shell inside the container.
    bind : bool, optional
        Bind-mount the current working directory into the container at
        ``/mnt/work`` and use it as the working directory.
    """
    if _ECR_PRIVATE_RE.match(image):
        from koopa.aws import aws_ecr_login_private

        aws_ecr_login_private()
    elif image.startswith("public.ecr.aws/"):
        if os.environ.get("AWS_ECR_PROFILE"):
            from koopa.aws import aws_ecr_login_public

            aws_ecr_login_public()
    _docker("pull", image)
    run_args: list[str] = ["--interactive", "--tty"]
    for var in ("HTTP_PROXY", "HTTPS_PROXY", "http_proxy", "https_proxy"):
        val = os.environ.get(var)
        if val:
            run_args.extend(["--env", f"{var}={val}"])
    if bind:
        cwd = os.getcwd()
        home = os.path.expanduser("~")
        if cwd == home:
            msg = "Do not set '--bind' when running at HOME."
            raise RuntimeError(msg)
        workdir = "/mnt/work"
        run_args.extend(
            [
                f"--volume={cwd}:{workdir}",
                f"--workdir={workdir}",
            ]
        )
    if arm:
        run_args.append("--platform=linux/arm64")
    elif x86:
        run_args.append("--platform=linux/amd64")
    run_args.append(image)
    if bash:
        run_args.extend(["bash", "-il"])
    _docker("run", *run_args)
