"""Download functions.

Converted from Bash/POSIX shell functions: download, download-cran-latest,
download-github-latest, etc.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

from . import archive


def download(
    url: str,
    output: str | None = None,
    *,
    decompress: bool = False,
) -> str:
    """Download a file from a URL.

    Uses curl if available, falling back to urllib.
    """
    if output is None:
        output = _derive_filename(url)
    Path(os.path.dirname(output) or ".").mkdir(parents=True, exist_ok=True)
    try:
        _download_curl(url, output)
    except FileNotFoundError, subprocess.CalledProcessError:
        _download_urllib(url, output)
    if decompress:
        output = archive.decompress(output)
    return output


def _derive_filename(url: str) -> str:
    """Derive filename from URL."""
    parsed = urlparse(url)
    name = os.path.basename(parsed.path)
    return name if name else "download"


def _download_curl(url: str, output: str) -> None:
    """Download using curl."""
    subprocess.run(
        ["curl", "-fsSL", "-o", output, url],
        check=True,
    )


def _download_urllib(url: str, output: str) -> None:
    """Download using urllib."""
    urllib.request.urlretrieve(url, output)


def download_cran_latest(package: str, output_dir: str = ".") -> str:
    """Download the latest CRAN package tarball."""
    url = f"https://cran.r-project.org/web/packages/{package}/"
    try:
        with urllib.request.urlopen(url) as resp:
            html = resp.read().decode()
    except Exception as e:
        msg = f"Failed to fetch CRAN page for {package}: {e}"
        raise RuntimeError(msg) from e
    match = re.search(rf"{package}_([\d.]+)\.tar\.gz", html)
    if not match:
        msg = f"Could not find tarball for {package} on CRAN."
        raise RuntimeError(msg)
    tarball = match.group(0)
    dl_url = f"https://cran.r-project.org/src/contrib/{tarball}"
    output = os.path.join(output_dir, tarball)
    return download(dl_url, output)


def download_github_latest(
    repo: str,
    output_dir: str = ".",
    *,
    pattern: str | None = None,
) -> str:
    """Download the latest GitHub release asset.

    Args:
        repo: GitHub repo in 'owner/repo' format.
        output_dir: Directory to save to.
        pattern: Optional regex pattern to match against asset names.
    """
    api_url = f"https://api.github.com/repos/{repo}/releases/latest"
    req = urllib.request.Request(api_url)
    req.add_header("Accept", "application/vnd.github+json")
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode())
    assets = data.get("assets", [])
    if not assets:
        tarball_url = data.get("tarball_url", "")
        if tarball_url:
            tag = data.get("tag_name", "latest")
            output = os.path.join(output_dir, f"{repo.rsplit('/', maxsplit=1)[-1]}-{tag}.tar.gz")
            return download(tarball_url, output)
        msg = f"No release assets found for {repo}."
        raise RuntimeError(msg)
    if pattern:
        rx = re.compile(pattern)
        matched = [a for a in assets if rx.search(a["name"])]
        if not matched:
            msg = f"No assets matching '{pattern}' for {repo}."
            raise RuntimeError(msg)
        asset = matched[0]
    else:
        asset = assets[0]
    dl_url = asset["browser_download_url"]
    output = os.path.join(output_dir, asset["name"])
    return download(dl_url, output)
