"""Current version scraping utilities.

Converted from Bash functions in ``lang/bash/functions/current/``.
Each function fetches a URL and parses the latest version string.
"""

from __future__ import annotations

import json
import re
import shutil
import subprocess
import urllib.request
from functools import lru_cache


def _fetch(url: str, *, list_only: bool = False) -> str:
    """Fetch URL content as text, mirroring ``_koopa_parse_url``."""
    if list_only and url.startswith("ftp://"):
        curl = shutil.which("curl")
        if curl is None:
            msg = "curl is required for FTP directory listings."
            raise RuntimeError(msg)
        result = subprocess.run(
            [
                curl,
                "--disable",
                "--fail",
                "--location",
                "--retry",
                "5",
                "--show-error",
                "--silent",
                "--list-only",
                url,
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "koopa/1.0")
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read().decode("utf-8", errors="replace")


def _version_sort_key(version: str) -> tuple[int, ...]:
    """Generate a sort key for version strings."""
    parts = re.split(r"[.\-_]", version)
    result: list[int] = []
    for part in parts:
        match = re.match(r"(\d+)", part)
        result.append(int(match.group(1)) if match else 0)
    return tuple(result)


def current_aws_cli_version() -> str:
    """Get the current AWS CLI version."""
    return current_github_tag_version("aws/aws-cli")


def current_bioconductor_version() -> str:
    """Current Bioconductor version."""
    text = _fetch("https://bioconductor.org/bioc-version")
    version = text.strip()
    if not version:
        msg = "Failed to fetch Bioconductor version."
        raise RuntimeError(msg)
    return version


def current_conda_package_version(name: str) -> str:
    """Get the current version of a conda package."""
    conda = shutil.which("conda")
    if conda is None:
        msg = "conda is not installed."
        raise RuntimeError(msg)
    result = subprocess.run(
        [conda, "search", name],
        capture_output=True,
        text=True,
        check=True,
    )
    lines = result.stdout.strip().splitlines()
    if not lines:
        msg = f"No conda package found: '{name}'."
        raise RuntimeError(msg)
    last_line = lines[-1]
    parts = last_line.split()
    if len(parts) < 2:
        msg = f"Unexpected conda search output for '{name}'."
        raise RuntimeError(msg)
    return parts[1]


def current_ensembl_version() -> str:
    """Current Ensembl version."""
    text = _fetch("ftp://ftp.ensembl.org/pub/README")
    lines = text.splitlines()
    if len(lines) < 3:
        msg = "Failed to parse Ensembl README."
        raise RuntimeError(msg)
    parts = lines[2].split()
    if len(parts) < 3:
        msg = "Failed to parse Ensembl version from README."
        raise RuntimeError(msg)
    return parts[2]


def current_flybase_version() -> str:
    """Current FlyBase version."""
    text = _fetch("ftp://ftp.flybase.net/releases/", list_only=True)
    pattern = re.compile(r"^(FB\d{4}_\d{2})$")
    matches = [m.group(1) for line in text.splitlines() if (m := pattern.match(line.strip()))]
    if not matches:
        msg = "Failed to fetch FlyBase version."
        raise RuntimeError(msg)
    return matches[-1]


def current_gencode_version(organism: str = "Homo sapiens") -> str:
    """Current GENCODE version."""
    if organism in ("Homo sapiens", "human"):
        short_name = "human"
        pattern = re.compile(r"Release (\d+)")
    elif organism in ("Mus musculus", "mouse"):
        short_name = "mouse"
        pattern = re.compile(r"Release (M\d+)")
    else:
        msg = f"Unsupported organism: '{organism}'."
        raise ValueError(msg)
    url = f"https://www.gencodegenes.org/{short_name}/"
    text = _fetch(url)
    match = pattern.search(text)
    if match is None:
        msg = "Failed to parse GENCODE version."
        raise RuntimeError(msg)
    return match.group(1)


def current_git_version() -> str:
    """Get current Git version from kernel.org."""
    url = "https://mirrors.edge.kernel.org/pub/software/scm/git/"
    text = _fetch(url)
    pattern = re.compile(r"git-([\d.]+)\.tar\.xz")
    matches = sorted(set(pattern.findall(text)), key=_version_sort_key)
    if not matches:
        msg = "Failed to fetch Git version."
        raise RuntimeError(msg)
    return matches[-1]


def current_github_release_version(repo: str) -> str:
    """Get the current release version from GitHub."""
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    text = _fetch(url)
    data = json.loads(text)
    tag = data.get("tag_name", "")
    if not tag:
        msg = f"Failed to fetch release version for '{repo}'."
        raise RuntimeError(msg)
    return re.sub(r"^v", "", tag)


def current_github_tag_version(repo: str) -> str:
    """Get the current tag version from GitHub."""
    url = f"https://api.github.com/repos/{repo}/tags"
    text = _fetch(url)
    data = json.loads(text)
    if not data:
        msg = f"No tags found for '{repo}'."
        raise RuntimeError(msg)
    names = [tag["name"] for tag in data]
    names.sort(key=_version_sort_key, reverse=True)
    return re.sub(r"^v", "", names[0])


def current_gnu_ftp_version(name: str) -> str:
    """Get current version from GNU FTP server."""
    url = f"https://mirrors.kernel.org/gnu/{name}/?C=M;O=D"
    text = _fetch(url)
    pattern = re.compile(rf"{re.escape(name)}-([\d.a-z]+)\.tar")
    matches = pattern.findall(text)
    if not matches:
        msg = f"Failed to fetch GNU FTP version for '{name}'."
        raise RuntimeError(msg)
    return matches[0]


@lru_cache(maxsize=1)
def current_google_cloud_sdk_version() -> str:
    """Get the current Google Cloud SDK version."""
    url = "https://cloud.google.com/sdk/docs/release-notes"
    text = _fetch(url)
    pattern = re.compile(r"<h2[^>]*>\s*([\d.]+)")
    match = pattern.search(text)
    if match is None:
        msg = "Failed to parse Google Cloud SDK version."
        raise RuntimeError(msg)
    return match.group(1)


def current_latch_version() -> str:
    """Current latch package version at PyPI."""
    return current_pypi_package_version("latch")


def current_pypi_package_version(name: str) -> str:
    """Current Python package version at PyPI."""
    url = f"https://pypi.org/pypi/{name}/json"
    text = _fetch(url)
    data = json.loads(text)
    version = data.get("info", {}).get("version", "")
    if not version:
        msg = f"Failed to fetch PyPI version for '{name}'."
        raise RuntimeError(msg)
    return version


def current_python_version() -> str:
    """Get current Python version from python.org."""
    url = "https://www.python.org/ftp/python/"
    text = _fetch(url)
    pattern = re.compile(r"(3\.\d+\.\d+)/")
    matches = sorted(set(pattern.findall(text)), key=_version_sort_key)
    if not matches:
        msg = "Failed to fetch Python version."
        raise RuntimeError(msg)
    # Return second-to-last (stable), matching bash tail -n 2 | head -n 1.
    if len(matches) >= 2:
        return matches[-2]
    return matches[-1]


def current_refseq_version() -> str:
    """Current RefSeq version."""
    url = "ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER"
    text = _fetch(url)
    version = text.strip()
    if not version:
        msg = "Failed to fetch RefSeq version."
        raise RuntimeError(msg)
    return version


def current_wormbase_version() -> str:
    """Current WormBase version."""
    url = "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/"
    text = _fetch(url, list_only=True)
    pattern = re.compile(r"(WS\d+)")
    match = pattern.search(text)
    if match is None:
        msg = "Failed to parse WormBase version."
        raise RuntimeError(msg)
    return match.group(1)
