"""Vendor backend support for custom S3 and JFrog Artifactory mirrors.

Configure via etc/koopa/vendor.json. When ``enabled`` is false (the default)
all functions return None/False and callers behave as if this module does not
exist.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from functools import lru_cache
from pathlib import Path
from typing import Any


@lru_cache(maxsize=1)
def vendor_config() -> dict[str, Any] | None:
    """Load vendor.json config. Returns None if missing, disabled, or invalid."""
    from koopa.prefix import koopa_prefix

    path = Path(koopa_prefix()) / "etc" / "koopa" / "vendor.json"
    if not path.is_file():
        return None
    try:
        data = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return None
    if not data.get("enabled", False):
        return None
    backend = data.get("backend", "")
    if backend not in ("s3", "artifactory"):
        print(
            f"vendor.json: unknown backend {backend!r}, ignoring.",
            file=sys.stderr,
        )
        return None
    return data


def _artifactory_token(cfg: dict[str, Any]) -> str | None:
    """Resolve the Artifactory Bearer token from the configured env var."""
    af = cfg.get("artifactory", {})
    env_var = af.get("token_env_var", "JFROG_ACCESS_TOKEN")
    return os.environ.get(env_var) or None


def _artifactory_src_url(cfg: dict[str, Any], name: str, filename: str) -> str:
    af = cfg["artifactory"]
    base = af["base_url"].rstrip("/")
    repo = af["src_repo"]
    return f"{base}/{repo}/src/{name}/{filename}"


def _artifactory_binary_url(
    cfg: dict[str, Any], os_str: str, arch: str, name: str, tarball: str
) -> str:
    af = cfg["artifactory"]
    base = af["base_url"].rstrip("/")
    repo = af["binary_repo"]
    return f"{base}/{repo}/binaries/{os_str}/{arch}/{name}/{tarball}"


def _s3_src_uri(cfg: dict[str, Any], name: str, filename: str) -> str:
    s3 = cfg["s3"]
    bucket = s3["bucket"]
    prefix = s3.get("src_prefix", "src").rstrip("/")
    return f"s3://{bucket}/{prefix}/{name}/{filename}"


def _s3_binary_uri(
    cfg: dict[str, Any], os_str: str, arch: str, name: str, tarball: str
) -> str:
    s3 = cfg["s3"]
    bucket = s3["bucket"]
    prefix = s3.get("binary_prefix", "binaries").rstrip("/")
    return f"s3://{bucket}/{prefix}/{os_str}/{arch}/{name}/{tarball}"


def vendor_download_src(name: str, filename: str) -> str | None:
    """Return HTTPS URL for source tarball from vendor backend, or None."""
    cfg = vendor_config()
    if cfg is None:
        return None
    backend = cfg["backend"]
    if backend == "artifactory":
        return _artifactory_src_url(cfg, name, filename)
    # S3 backend — return None; callers use aws s3 cp directly via vendor_pull_src
    return None


def vendor_download_binary(
    os_str: str, arch: str, name: str, tarball: str
) -> str | None:
    """Return HTTPS URL for binary tarball from vendor Artifactory backend, or None.

    For S3 backend returns None (callers use vendor_pull_binary instead).
    """
    cfg = vendor_config()
    if cfg is None:
        return None
    if cfg["backend"] == "artifactory":
        return _artifactory_binary_url(cfg, os_str, arch, name, tarball)
    return None


def vendor_has_src(name: str, filename: str) -> bool:
    """Return True if the source tarball exists in the vendor backend."""
    cfg = vendor_config()
    if cfg is None:
        return False
    backend = cfg["backend"]
    if backend == "artifactory":
        url = _artifactory_src_url(cfg, name, filename)
        token = _artifactory_token(cfg)
        return _artifactory_head(url, token)
    # S3
    uri = _s3_src_uri(cfg, name, filename)
    return _s3_head(uri, cfg["s3"].get("profile", ""))


def vendor_has_binary(os_str: str, arch: str, name: str, tarball: str) -> bool:
    """Return True if the binary tarball exists in the vendor backend."""
    cfg = vendor_config()
    if cfg is None:
        return False
    backend = cfg["backend"]
    if backend == "artifactory":
        url = _artifactory_binary_url(cfg, os_str, arch, name, tarball)
        token = _artifactory_token(cfg)
        return _artifactory_head(url, token)
    uri = _s3_binary_uri(cfg, os_str, arch, name, tarball)
    return _s3_head(uri, cfg["s3"].get("profile", ""))


def vendor_pull_binary(
    os_str: str, arch: str, name: str, tarball: str, dest: str
) -> None:
    """Download binary tarball from vendor backend to dest path."""
    cfg = vendor_config()
    if cfg is None:
        msg = "No vendor config."
        raise RuntimeError(msg)
    backend = cfg["backend"]
    if backend == "artifactory":
        url = _artifactory_binary_url(cfg, os_str, arch, name, tarball)
        token = _artifactory_token(cfg)
        _artifactory_download(url, dest, token)
    else:
        uri = _s3_binary_uri(cfg, os_str, arch, name, tarball)
        profile = cfg["s3"].get("profile", "")
        _s3_cp(uri, dest, profile)


def vendor_push_src(local_path: str, name: str, filename: str) -> None:
    """Upload source tarball to vendor backend."""
    cfg = vendor_config()
    if cfg is None:
        return
    backend = cfg["backend"]
    if backend == "artifactory":
        url = _artifactory_src_url(cfg, name, filename)
        token = _artifactory_token(cfg)
        _artifactory_upload(local_path, url, token)
    else:
        uri = _s3_src_uri(cfg, name, filename)
        profile = cfg["s3"].get("profile", "")
        _s3_cp(local_path, uri, profile)


def vendor_push_binary(
    local_path: str, os_str: str, arch: str, name: str, tarball: str
) -> None:
    """Upload binary tarball to vendor backend."""
    cfg = vendor_config()
    if cfg is None:
        return
    backend = cfg["backend"]
    if backend == "artifactory":
        url = _artifactory_binary_url(cfg, os_str, arch, name, tarball)
        token = _artifactory_token(cfg)
        _artifactory_upload(local_path, url, token)
    else:
        uri = _s3_binary_uri(cfg, os_str, arch, name, tarball)
        profile = cfg["s3"].get("profile", "")
        _s3_cp(local_path, uri, profile)


def vendor_can_pull() -> bool:
    """Return True if the vendor backend is configured and pull credentials are available."""
    cfg = vendor_config()
    if cfg is None:
        return False
    if cfg["backend"] == "artifactory":
        # Anonymous read is allowed; token only needed for private repos.
        return True
    # S3 — just needs aws CLI
    return bool(_find_aws())


def vendor_can_push() -> bool:
    """Return True if the vendor backend is configured and push credentials are available."""
    cfg = vendor_config()
    if cfg is None:
        return False
    if cfg["backend"] == "artifactory":
        return bool(_artifactory_token(cfg))
    # S3 — needs aws CLI and a named profile
    if not _find_aws():
        return False
    profile = cfg["s3"].get("profile", "")
    if not profile:
        return False
    creds = Path.home() / ".aws" / "credentials"
    if not creds.is_file():
        return False
    import re

    return bool(re.search(rf"^\[{re.escape(profile)}\]$", creds.read_text(), re.MULTILINE))


def vendor_pull_priority() -> str:
    """Return 'vendor_first' or 'vendor_only'. Defaults to 'vendor_first'."""
    cfg = vendor_config()
    if cfg is None:
        return "vendor_first"
    return cfg.get("pull_priority", "vendor_first")


# ---------------------------------------------------------------------------
# Low-level helpers
# ---------------------------------------------------------------------------


def _find_aws() -> str | None:
    import shutil

    return shutil.which("aws")


def _s3_cp(src: str, dest: str, profile: str) -> None:
    cmd = ["aws", "s3", "cp"]
    if profile:
        cmd += ["--profile", profile]
    cmd += [src, dest]
    subprocess.run(cmd, check=True)


def _s3_head(uri: str, profile: str) -> bool:
    import re

    match = re.match(r"s3://([^/]+)/(.+)", uri)
    if not match:
        return False
    bucket, key = match.group(1), match.group(2)
    cmd = ["aws", "s3api", "head-object", "--bucket", bucket, "--key", key]
    if profile:
        cmd += ["--profile", profile]
    result = subprocess.run(cmd, capture_output=True, check=False)
    return result.returncode == 0


def _artifactory_head(url: str, token: str | None) -> bool:
    cmd = ["curl", "-sI", "--fail", "-o", "/dev/null"]
    if token:
        cmd += ["-H", f"Authorization: Bearer {token}"]
    cmd.append(url)
    result = subprocess.run(cmd, capture_output=True, check=False)
    return result.returncode == 0


def _artifactory_download(url: str, dest: str, token: str | None) -> None:
    cmd = ["curl", "-fsSL", "-o", dest]
    if token:
        cmd += ["-H", f"Authorization: Bearer {token}"]
    cmd.append(url)
    subprocess.run(cmd, check=True)


def _artifactory_upload(local_path: str, url: str, token: str | None) -> None:
    cmd = ["curl", "-fsSL", "-T", local_path]
    if token:
        cmd += ["-H", f"Authorization: Bearer {token}"]
    cmd.append(url)
    subprocess.run(cmd, check=True)
