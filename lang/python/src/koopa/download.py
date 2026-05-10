"""Download functions.

Converted from Bash/POSIX shell functions: download, download-cran-latest,
download-github-latest, etc.
"""

import json
import os
import re
import ssl
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
    retry: bool = True,
    connect_timeout: int | None = None,
    max_time: int | None = None,
    quiet: bool = False,
) -> str:
    """Download a file from a URL.

    Uses curl if available, falling back to urllib.
    """
    if output is None:
        output = _derive_filename(url)
    Path(os.path.dirname(output) or ".").mkdir(parents=True, exist_ok=True)
    if not quiet:
        print(f"Downloading '{url}' to '{output}'.", file=sys.stderr)
    try:
        _download_curl(
            url,
            output,
            retry=retry,
            connect_timeout=connect_timeout,
            max_time=max_time,
            quiet=quiet,
        )
    except (FileNotFoundError, RuntimeError, subprocess.CalledProcessError):
        try:
            _download_curl(
                url,
                output,
                retry=retry,
                connect_timeout=connect_timeout,
                max_time=max_time,
                curl_cmd="/usr/bin/curl",
                quiet=quiet,
            )
        except (FileNotFoundError, RuntimeError, subprocess.CalledProcessError):
            _download_urllib(url, output)
    if decompress:
        output = archive.decompress(output)
    return output


def _gnu_mirrors(primary_url: str, name: str, filename: str) -> list[str]:
    """Return alternative GNU mirror URLs if primary is a GNU source."""
    if "ftpmirror.gnu.org" not in primary_url and "ftp.gnu.org" not in primary_url:
        return []
    return [
        f"https://ftp.gnu.org/gnu/{name}/{filename}",
        f"https://mirrors.kernel.org/gnu/{name}/{filename}",
        f"https://mirror.rit.edu/gnu/{name}/{filename}",
    ]


def _savannah_mirrors(primary_url: str, name: str, filename: str) -> list[str]:
    """Return alternative Savannah mirror URLs if primary is a Savannah source."""
    if "download.savannah.nongnu.org" not in primary_url:
        return []
    return [
        f"https://nongnu.uib.no/{name}/{filename}",
        f"https://mirror.csclub.uwaterloo.ca/nongnu/{name}/{filename}",
        f"https://mirrors.ocf.berkeley.edu/nongnu/{name}/{filename}",
    ]


def download_with_mirror(
    primary_url: str,
    name: str,
    filename: str,
    *,
    extra_urls: list[str] | None = None,
    connect_timeout: int = 10,
    max_time: int | None = None,
    output: str | None = None,
    quiet: bool = False,
    skip_koopa_mirror: bool = False,
) -> str:
    """Download from primary URL, falling back to mirrors.

    Tries the primary URL first, then GNU mirrors (if applicable), then
    Savannah mirrors (if applicable), then any extra_urls, then the koopa
    mirror at https://koopa.acidgenomics.com/src/{name}/{filename}.

    Uses a short connect_timeout on mirror attempts so broken TLS endpoints
    fail fast instead of blocking for minutes on retries.
    """
    koopa_mirror = f"https://koopa.acidgenomics.com/src/{name}/{filename}"
    urls = [primary_url]
    urls.extend(_gnu_mirrors(primary_url, name, filename))
    urls.extend(_savannah_mirrors(primary_url, name, filename))
    urls.extend(extra_urls or [])
    if not skip_koopa_mirror:
        urls.append(koopa_mirror)
    last_exc: Exception | None = None
    for i, url in enumerate(urls):
        try:
            is_last = not skip_koopa_mirror and url == koopa_mirror
            tarball = download(
                url,
                output,
                retry=False,
                connect_timeout=connect_timeout if not is_last else None,
                max_time=max_time,
                quiet=quiet,
            )
            if not archive.is_valid_archive(tarball):
                raise ValueError("invalid archive")
            return tarball
        except Exception as exc:
            last_exc = exc
            if i < len(urls) - 1:
                next_url = urls[i + 1]
                if not quiet:
                    print(
                        f"All mirrors failed, trying koopa mirror: '{next_url}'."
                        if next_url == koopa_mirror
                        else f"Mirror failed, trying: '{next_url}'.",
                        file=sys.stderr,
                    )
    assert last_exc is not None
    raise last_exc


def _derive_filename(url: str) -> str:
    """Derive filename from URL, stripping query strings and decoding."""
    parsed = urlparse(url)
    name = os.path.basename(parsed.path)
    if not name or name == "download":
        name = os.path.basename(os.path.dirname(parsed.path))
    name = name.split("?")[0]
    name = unquote(name)
    return name if name else "download"


_curl_ok: set[str] = set()


def _check_curl(curl_cmd: str) -> None:
    """Verify curl's RPATH targets exist. Runs once per curl_cmd."""
    if curl_cmd in _curl_ok:
        return
    import shutil

    from koopa.build import _check_rpath
    from koopa.prefix import koopa_prefix

    koopa_bin = os.path.join(koopa_prefix(), "bin", "curl")
    resolved = shutil.which(curl_cmd)
    if resolved and os.path.realpath(resolved) == os.path.realpath(koopa_bin):
        prefix = os.path.dirname(os.path.dirname(os.path.realpath(resolved)))
        _check_rpath(prefix, "curl")
    _curl_ok.add(curl_cmd)


def _download_curl(
    url: str,
    output: str,
    *,
    retry: bool = True,
    connect_timeout: int | None = None,
    max_time: int | None = None,
    curl_cmd: str = "curl",
    quiet: bool = False,
) -> None:
    """Download using curl."""
    _check_curl(curl_cmd)
    curl_args = [
        curl_cmd,
        "--create-dirs",
        "--fail",
        "--location",
        "--show-error",
        "-o",
        output,
    ]
    if quiet:
        curl_args.append("--silent")
    if connect_timeout is not None:
        curl_args.extend(["--connect-timeout", str(connect_timeout)])
    if max_time is not None:
        curl_args.extend(["--max-time", str(max_time)])
    if retry:
        curl_args.extend(["--retry", "3", "--retry-delay", "5", "--retry-all-errors"])
    ca_bundle = os.environ.get("CURL_CA_BUNDLE") or os.environ.get("SSL_CERT_FILE")
    if ca_bundle and os.path.isfile(ca_bundle):
        curl_args.extend(["--cacert", ca_bundle])
    if "sourceforge.net/" in url:
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
    ca_bundle = os.environ.get("CURL_CA_BUNDLE") or os.environ.get("SSL_CERT_FILE")
    if ca_bundle and not os.path.isfile(ca_bundle):
        ca_bundle = None
    ssl_ctx = ssl.create_default_context(cafile=ca_bundle) if ca_bundle else None
    opener = (
        urllib.request.build_opener(urllib.request.HTTPSHandler(context=ssl_ctx))
        if ssl_ctx
        else None
    )
    open_fn = opener.open if opener else urllib.request.urlopen
    with open_fn(req, timeout=300) as resp, open(output, "wb") as f:
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
