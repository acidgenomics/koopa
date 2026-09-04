"""Vendor backend support for custom S3 and HTTP(S) repository mirrors.

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
from urllib.parse import urlparse


@lru_cache(maxsize=1)
def vendor_config() -> dict[str, Any] | None:
    """Load vendor.json config. Returns None if missing, disabled, or invalid.

    Checked in order, first existing file wins (not merged):
    '${XDG_CONFIG_HOME:-~/.config}/koopa/vendor.json', then
    '<koopa-prefix>/etc/koopa/vendor.json'. The XDG location survives a
    pinned-release re-extract or 'git clean', since it lives outside the koopa
    tree entirely; the 'etc/koopa/' location is kept for continuity with
    existing setups and the shipped '.example' file.

    Returns
    -------
    dict[str, Any] | None
        Parsed vendor config if a valid, enabled config file exists,
        otherwise None.
    """
    from koopa.prefix import koopa_prefix
    from koopa.xdg import xdg_config_home

    candidates = [
        Path(xdg_config_home()) / "koopa" / "vendor.json",
        Path(koopa_prefix()) / "etc" / "koopa" / "vendor.json",
    ]
    path = next((c for c in candidates if c.is_file()), None)
    if path is None:
        return None
    try:
        data = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return None
    if not data.get("enabled", False):
        return None
    backend = data.get("backend", "")
    if backend not in ("s3", "http"):
        print(
            f"vendor.json: unknown backend {backend!r}, ignoring.",
            file=sys.stderr,
        )
        return None
    return data


def _http_token(cfg: dict[str, Any]) -> str | None:
    """Resolve the HTTP Bearer token from the configured env var.

    Parameters
    ----------
    cfg : dict[str, Any]
        Parsed vendor config.

    Returns
    -------
    str | None
        Token value from the configured environment variable, or None if unset.
    """
    hc = cfg.get("http", {})
    env_var = hc.get("token_env_var", "HTTP_ACCESS_TOKEN")
    return os.environ.get(env_var) or None


def _http_src_url(cfg: dict[str, Any], name: str, filename: str) -> str:
    hc = cfg["http"]
    base = hc["base_url"].rstrip("/")
    repo = hc["src_repo"]
    return f"{base}/{repo}/src/{name}/{filename}"


def _http_binary_url(cfg: dict[str, Any], os_str: str, arch: str, name: str, tarball: str) -> str:
    hc = cfg["http"]
    base = hc["base_url"].rstrip("/")
    repo = hc["binary_repo"]
    return f"{base}/{repo}/binaries/{os_str}/{arch}/{name}/{tarball}"


def _remote_repo_for_host(cfg: dict[str, Any], host: str) -> str | None:
    """Return the remote-proxy repo name for a host, or None if unmapped.

    Parameters
    ----------
    cfg : dict[str, Any]
        Parsed vendor config.
    host : str
        Hostname to look up in the 'http.remotes' map.

    Returns
    -------
    str | None
        Matching remote-proxy repo name, or None if the host has no mapping.
    """
    remotes = cfg.get("http", {}).get("remotes") or {}
    if host in remotes:
        return remotes[host]
    for key, repo in remotes.items():
        if key.startswith(".") and host.endswith(key):
            return repo
    return None


def _s3_src_uri(cfg: dict[str, Any], name: str, filename: str) -> str:
    s3 = cfg["s3"]
    bucket = s3["bucket"]
    prefix = s3.get("src_prefix", "src").rstrip("/")
    return f"s3://{bucket}/{prefix}/{name}/{filename}"


def _s3_binary_uri(cfg: dict[str, Any], os_str: str, arch: str, name: str, tarball: str) -> str:
    s3 = cfg["s3"]
    bucket = s3["bucket"]
    prefix = s3.get("binary_prefix", "binaries").rstrip("/")
    return f"s3://{bucket}/{prefix}/{os_str}/{arch}/{name}/{tarball}"


def vendor_download_src(name: str, filename: str) -> str | None:
    """Return HTTPS URL for source tarball from vendor backend, or None.

    Parameters
    ----------
    name : str
        Application name.
    filename : str
        Source tarball filename.

    Returns
    -------
    str | None
        HTTPS URL for the source tarball, or None if no HTTP vendor backend
        is configured.
    """
    cfg = vendor_config()
    if cfg is None:
        return None
    backend = cfg["backend"]
    if backend == "http":
        return _http_src_url(cfg, name, filename)
    # S3 backend — return None; callers use aws s3 cp directly via vendor_pull_src
    return None


def vendor_download_binary(os_str: str, arch: str, name: str, tarball: str) -> str | None:
    """Return HTTPS URL for binary tarball from vendor HTTP backend, or None.

    For S3 backend returns None (callers use vendor_pull_binary instead).

    Parameters
    ----------
    os_str : str
        Operating system platform slug.
    arch : str
        CPU architecture slug.
    name : str
        Application name.
    tarball : str
        Binary tarball filename.

    Returns
    -------
    str | None
        HTTPS URL for the binary tarball, or None if no HTTP vendor backend
        is configured.
    """
    cfg = vendor_config()
    if cfg is None:
        return None
    if cfg["backend"] == "http":
        return _http_binary_url(cfg, os_str, arch, name, tarball)
    return None


def vendor_rewrite_url(url: str) -> str | None:
    """Rewrite an upstream URL through a vendor remote-proxy repo, or None.

    Requires backend 'http' and a configured 'http.remotes' host -> repo map
    (e.g. {"github.com": "github-remote"}). The URL's hostname is matched
    exactly first, then against 'remotes' keys beginning with '.' as a
    suffix match (e.g. '.gnu.org' matches 'ftpmirror.gnu.org'). A remote
    repo's root mirrors the proxied host's root, so the rewritten URL keeps
    the original path and query string.

    Parameters
    ----------
    url : str
        Upstream URL to rewrite.

    Returns
    -------
    str | None
        Rewritten URL through the matching remote-proxy repo, or None if no
        HTTP vendor backend is configured or the host has no remote mapping.
    """
    cfg = vendor_config()
    if cfg is None or cfg.get("backend") != "http":
        return None
    parsed = urlparse(url)
    repo = _remote_repo_for_host(cfg, parsed.hostname or "")
    if repo is None:
        return None
    base = cfg["http"]["base_url"].rstrip("/")
    path = parsed.path
    if parsed.query:
        path = f"{path}?{parsed.query}"
    return f"{base}/{repo}{path}"


def vendor_has_src(name: str, filename: str) -> bool:
    """Return True if the source tarball exists in the vendor backend.

    Parameters
    ----------
    name : str
        Application name.
    filename : str
        Source tarball filename.

    Returns
    -------
    bool
        True if the source tarball exists in the configured vendor backend.
    """
    cfg = vendor_config()
    if cfg is None:
        return False
    backend = cfg["backend"]
    if backend == "http":
        url = _http_src_url(cfg, name, filename)
        token = _http_token(cfg)
        return _http_head(url, token)
    # S3
    uri = _s3_src_uri(cfg, name, filename)
    return _s3_head(uri, cfg["s3"].get("profile", ""))


def vendor_has_binary(os_str: str, arch: str, name: str, tarball: str) -> bool:
    """Return True if the binary tarball exists in the vendor backend.

    Parameters
    ----------
    os_str : str
        Operating system platform slug.
    arch : str
        CPU architecture slug.
    name : str
        Application name.
    tarball : str
        Binary tarball filename.

    Returns
    -------
    bool
        True if the binary tarball exists in the configured vendor backend.
    """
    cfg = vendor_config()
    if cfg is None:
        return False
    backend = cfg["backend"]
    if backend == "http":
        url = _http_binary_url(cfg, os_str, arch, name, tarball)
        token = _http_token(cfg)
        return _http_head(url, token)
    uri = _s3_binary_uri(cfg, os_str, arch, name, tarball)
    return _s3_head(uri, cfg["s3"].get("profile", ""))


def vendor_pull_binary(os_str: str, arch: str, name: str, tarball: str, dest: str) -> None:
    """Download binary tarball from vendor backend to dest path.

    Parameters
    ----------
    os_str : str
        Operating system platform slug.
    arch : str
        CPU architecture slug.
    name : str
        Application name.
    tarball : str
        Binary tarball filename.
    dest : str
        Local file path to download the tarball to.
    """
    cfg = vendor_config()
    if cfg is None:
        msg = "No vendor config."
        raise RuntimeError(msg)
    backend = cfg["backend"]
    if backend == "http":
        url = _http_binary_url(cfg, os_str, arch, name, tarball)
        token = _http_token(cfg)
        _http_download(url, dest, token)
    else:
        uri = _s3_binary_uri(cfg, os_str, arch, name, tarball)
        profile = cfg["s3"].get("profile", "")
        _s3_cp(uri, dest, profile)


def vendor_push_src(local_path: str, name: str, filename: str) -> None:
    """Upload source tarball to vendor backend.

    Parameters
    ----------
    local_path : str
        Local file path of the source tarball to upload.
    name : str
        Application name.
    filename : str
        Source tarball filename to upload to.
    """
    cfg = vendor_config()
    if cfg is None:
        return
    backend = cfg["backend"]
    if backend == "http":
        url = _http_src_url(cfg, name, filename)
        token = _http_token(cfg)
        _http_upload(local_path, url, token)
    else:
        uri = _s3_src_uri(cfg, name, filename)
        profile = cfg["s3"].get("profile", "")
        _s3_cp(local_path, uri, profile)


def vendor_push_binary(local_path: str, os_str: str, arch: str, name: str, tarball: str) -> None:
    """Upload binary tarball to vendor backend.

    Parameters
    ----------
    local_path : str
        Local file path of the binary tarball to upload.
    os_str : str
        Operating system platform slug.
    arch : str
        CPU architecture slug.
    name : str
        Application name.
    tarball : str
        Binary tarball filename to upload to.
    """
    cfg = vendor_config()
    if cfg is None:
        return
    backend = cfg["backend"]
    if backend == "http":
        url = _http_binary_url(cfg, os_str, arch, name, tarball)
        token = _http_token(cfg)
        _http_upload(local_path, url, token)
    else:
        uri = _s3_binary_uri(cfg, os_str, arch, name, tarball)
        profile = cfg["s3"].get("profile", "")
        _s3_cp(local_path, uri, profile)


def vendor_can_pull() -> bool:
    """Return True if the vendor backend is configured and pull credentials are available.

    Returns
    -------
    bool
        True if a vendor backend is configured and can be read from.
    """
    cfg = vendor_config()
    if cfg is None:
        return False
    if cfg["backend"] == "http":
        # Anonymous read is allowed; token only needed for private repos.
        return True
    # S3 — just needs aws CLI
    return bool(_find_aws())


def vendor_can_push() -> bool:
    """Return True if the vendor backend is configured and push credentials are available.

    Returns
    -------
    bool
        True if a vendor backend is configured and push credentials are available.
    """
    cfg = vendor_config()
    if cfg is None:
        return False
    if cfg["backend"] == "http":
        return bool(_http_token(cfg))
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
    """Return 'vendor_first' or 'vendor_only'. Defaults to 'vendor_first'.

    Returns
    -------
    str
        Pull priority mode: 'vendor_first' or 'vendor_only'.
    """
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
    cmd = ["aws", "s3", "cp", "--only-show-errors"]
    if profile:
        cmd += ["--profile", profile]
    cmd += [src, dest]
    subprocess.run(cmd, capture_output=True, check=True)


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


def _http_head(url: str, token: str | None) -> bool:
    cmd = ["curl", "-sI", "--fail", "-o", "/dev/null"]
    if token:
        cmd += ["-H", f"Authorization: Bearer {token}"]
    cmd.append(url)
    result = subprocess.run(cmd, capture_output=True, check=False)
    return result.returncode == 0


def _http_download(url: str, dest: str, token: str | None) -> None:
    cmd = ["curl", "-fsSL", "-o", dest]
    if token:
        cmd += ["-H", f"Authorization: Bearer {token}"]
    cmd.append(url)
    subprocess.run(cmd, check=True)


def _http_upload(local_path: str, url: str, token: str | None) -> None:
    cmd = ["curl", "-fsSL", "-T", local_path]
    if token:
        cmd += ["-H", f"Authorization: Bearer {token}"]
    cmd.append(url)
    subprocess.run(cmd, check=True)
