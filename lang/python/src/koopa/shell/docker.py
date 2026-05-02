"""Docker image management functions.

Converted from Bash functions in ``lang/bash/functions/docker/``.
"""

from __future__ import annotations

import os
import re
import subprocess
from datetime import datetime, timezone
from os.path import abspath, basename, expanduser, isdir, isfile, join
from pathlib import Path

from koopa.fs import list_subdirs


def _docker(*args: str, check: bool = True, **kwargs) -> subprocess.CompletedProcess:
    """Run a docker command."""
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
        [docker, *args], check=check, env=env, **kwargs,
    )


def build(
    *,
    local: str,
    remote: str,
    memory: str = "",
    no_push: bool = False,
) -> None:
    """Build and push a multi-architecture Docker image using buildx."""
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
            line.strip()
            for line in Path(tags_file).read_text().splitlines()
            if line.strip()
        )
    if os.path.islink(local):
        tags.append(tag)
        local = os.path.realpath(local)
        tag = basename(local)
    date_tag = datetime.now(tz=timezone.utc).strftime("%Y%m%d")
    tags.extend([tag, f"{tag}-{date_tag}"])
    tags = sorted(set(tags))
    platforms = ["linux/amd64"]
    platforms_file = join(local, "platforms.txt")
    if isfile(platforms_file):
        platforms = [
            line.strip()
            for line in Path(platforms_file).read_text().splitlines()
            if line.strip()
        ]
    build_args: list[str] = []
    for t in tags:
        build_args.append(f"--tag={image_name}:{t}")
    build_args.append(f"--platform={','.join(platforms)}")
    if memory:
        build_args.extend([
            f"--memory={memory}",
            f"--memory-swap={memory}",
        ])
    build_args.extend(["--no-cache", "--progress=auto", "--pull"])
    if push:
        build_args.append("--push")
    build_args.append(local)
    # Prune existing locally tagged images.
    result = _docker(
        "image", "ls", "--filter", f"reference={remote}", "--quiet",
        capture_output=True, text=True, check=False,
    )
    image_ids = [x for x in result.stdout.strip().splitlines() if x]
    if image_ids:
        _docker("image", "rm", "--force", *image_ids, check=False)
    print(f"Building '{remote}' Docker image.")
    build_name = basename(image_name)
    _docker("buildx", "rm", build_name, check=False,
            capture_output=True)
    _docker("buildx", "create", f"--name={build_name}", "--use",
            capture_output=True)
    try:
        _docker("buildx", "build", *build_args)
    finally:
        _docker("buildx", "rm", build_name, check=False,
                capture_output=True)
    _docker("image", "ls", "--filter", f"reference={remote}")
    if push:
        _docker("logout", server, check=False, capture_output=True)
    print(f"Build of '{remote}' was successful.")


def _authenticate(server: str) -> None:
    """Authenticate with a Docker registry."""
    if ".dkr.ecr." in server and ".amazonaws.com" in server:
        from koopa.aws import aws_ecr_login_private
        aws_ecr_login_private()
    elif server == "public.ecr.aws":
        from koopa.aws import aws_ecr_login_public
        aws_ecr_login_public()
    else:
        _docker("logout", server, check=False, capture_output=True)
        _docker("login", server)


def build_all_tags(local: str, remote: str) -> None:
    """Build all Docker tags from subdirectories."""
    local = abspath(expanduser(local))
    if not isdir(local):
        msg = f"Directory does not exist: '{local}'."
        raise FileNotFoundError(msg)
    tags = list_subdirs(
        path=local, recursive=False, sort=True, basename_only=True,
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
    proc = subprocess.run(
        ["docker", "login", "ghcr.io", "-u", user, "--password-stdin"],
        input=pat, text=True, check=True,
    )


def ghcr_push(owner: str, image_name: str, version: str) -> None:
    """Push an image to GitHub Container Registry."""
    url = f"ghcr.io/{owner}/{image_name}:{version}"
    ghcr_login()
    _docker("push", url)


def is_build_recent(*images: str, days: int = 7) -> bool:
    """Check if Docker images were built within N days."""
    seconds = days * 86400
    now = datetime.now(tz=timezone.utc)
    for image in images:
        _docker("pull", image, capture_output=True)
        result = _docker(
            "inspect", "--format={{json .Created}}", image,
            capture_output=True, text=True,
        )
        created_str = result.stdout.strip().strip('"')
        match = re.search(
            r"(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})", created_str,
        )
        if match is None:
            return False
        dt_str = f"{match.group(1)} {match.group(2)} UTC"
        created = datetime.strptime(dt_str, "%Y-%m-%d %H:%M %Z").replace(
            tzinfo=timezone.utc,
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
        "image", "prune", "--all", "--filter", "until=2160h", "--force",
        check=False,
    )
    _docker("image", "prune", "--force", check=False)


def remove(*patterns: str) -> None:
    """Remove Docker images by pattern matching."""
    for pattern in patterns:
        result = _docker(
            "images", capture_output=True, text=True, check=False,
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
    """Run a Docker image interactively."""
    if ".dkr.ecr." in image and ".amazonaws.com/" in image:
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
        run_args.extend([
            f"--volume={cwd}:{workdir}",
            f"--workdir={workdir}",
        ])
    if arm:
        run_args.append("--platform=linux/arm64")
    elif x86:
        run_args.append("--platform=linux/amd64")
    run_args.append(image)
    if bash:
        run_args.extend(["bash", "-il"])
    _docker("run", *run_args)
