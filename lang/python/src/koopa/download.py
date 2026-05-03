"""Download functions.

Converted from Bash/POSIX shell functions: download, download-cran-latest,
download-github-latest, etc.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.request
from pathlib import Path
from urllib.parse import unquote, urlparse

from . import archive

_USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 "
    "Safari/537.36 Edg/131.0.0.0"
)


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
    print(f"Downloading '{url}' to '{output}'.", file=sys.stderr)
    try:
        _download_curl(url, output)
    except (FileNotFoundError, subprocess.CalledProcessError):
        _download_urllib(url, output)
    if decompress:
        output = archive.decompress(output)
    return output


def _derive_filename(url: str) -> str:
    """Derive filename from URL, stripping query strings and decoding."""
    parsed = urlparse(url)
    name = os.path.basename(parsed.path)
    if not name or name == "download":
        name = os.path.basename(os.path.dirname(parsed.path))
    name = name.split("?")[0]
    name = unquote(name)
    return name if name else "download"


def _download_curl(url: str, output: str) -> None:
    """Download using curl."""
    curl_args = [
        "curl",
        "--create-dirs",
        "--fail",
        "--location",
        "--retry",
        "5",
        "--show-error",
        "-o",
        output,
    ]
    if "sourceforge.net/" not in url:
        curl_args.extend(["--user-agent", _USER_AGENT])
    if os.environ.get("http_proxy") or os.environ.get("https_proxy"):
        curl_args.append("--insecure")
    if os.environ.get("KOOPA_VERBOSE") == "1":
        curl_args.append("--verbose")
    curl_args.append(url)
    subprocess.run(curl_args, check=True)


def _download_urllib(url: str, output: str) -> None:
    """Download using urllib."""
    req = urllib.request.Request(url)
    req.add_header("User-Agent", _USER_AGENT)
    with urllib.request.urlopen(req) as resp, open(output, "wb") as f:
        total = resp.headers.get("Content-Length")
        if total is not None:
            total = int(total)
        downloaded = 0
        block_size = 65536
        while True:
            chunk = resp.read(block_size)
            if not chunk:
                break
            f.write(chunk)
            downloaded += len(chunk)
            if total:
                pct = downloaded * 100 // total
                sys.stderr.write(f"\r  {pct}%")
                sys.stderr.flush()
        if total:
            sys.stderr.write("\n")


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
