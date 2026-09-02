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
from functools import lru_cache
from pathlib import Path
from urllib.parse import unquote, urlparse

from . import archive

_USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 "
    "Safari/537.36 Edg/131.0.0.0"
)


def _is_sourceforge_url(url: str) -> bool:
    """Return whether a URL points at sourceforge.net or a subdomain."""
    host = urlparse(url).hostname or ""
    return host == "sourceforge.net" or host.endswith(".sourceforge.net")


# Extensions that archive.is_valid_archive() can actually recognize by magic
# bytes (gzip, bzip2, xz, zstd, lzip), matching archive.extract()/decompress().
# A src_url can point at a non-archive payload (e.g. bash-preexec's
# bash-preexec.sh), which should not be run through that check.
_ARCHIVE_EXTS = (
    ".tar.gz",
    ".tar.bz2",
    ".tar.xz",
    ".tar.zst",
    ".tar.zstd",
    ".tar.lz",
    ".tgz",
    ".tbz2",
    ".txz",
    ".gz",
    ".bz2",
    ".xz",
    ".zst",
    ".zstd",
    ".lz",
)


def download(
    url: str,
    output: str | None = None,
    *,
    decompress: bool = False,
    retry: bool = True,
    connect_timeout: int | None = None,
    max_time: int | None = None,
    speed_limit: int | None = None,
    speed_time: int | None = None,
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
            speed_limit=speed_limit,
            speed_time=speed_time,
            quiet=quiet,
        )
    except (FileNotFoundError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(
            f"  Download failed for '{url}' ({exc}); retrying with /usr/bin/curl.",
            file=sys.stderr,
        )
        try:
            _download_curl(
                url,
                output,
                retry=retry,
                connect_timeout=connect_timeout,
                max_time=max_time,
                speed_limit=speed_limit,
                speed_time=speed_time,
                curl_cmd="/usr/bin/curl",
                quiet=quiet,
            )
        except (FileNotFoundError, RuntimeError, subprocess.CalledProcessError) as exc2:
            print(f"  Download failed for '{url}' ({exc2}); retrying with urllib.", file=sys.stderr)
            _download_urllib(url, output)
    if decompress:
        output = archive.decompress(output)
    return output


_GNU_HOSTS = ("ftpmirror.gnu.org", "ftp.gnu.org", "mirrors.kernel.org")
_GNU_MIRROR_BASES = (
    "https://mirrors.kernel.org/gnu/",
    "https://ftp.wayne.edu/gnu/",
    "https://mirrors.ocf.berkeley.edu/gnu/",
    "https://mirror.csclub.uwaterloo.ca/gnu/",
)

_GNUPG_HOSTS = ("ftp.gnupg.org", "gnupg.org", "www.gnupg.org")
_GNUPG_MIRROR_BASES = (
    "https://www.gnupg.org/ftp/gcrypt/",
    "https://gnupg.org/ftp/gcrypt/",
)

_NONGNU_HOSTS = ("download.savannah.nongnu.org", "mirror.csclub.uwaterloo.ca")
_NONGNU_MIRROR_BASES = (
    "https://mirror.csclub.uwaterloo.ca/nongnu/",
    "https://mirrors.ocf.berkeley.edu/nongnu/",
    "https://nongnu.uib.no/",
)


def _gnu_relative_path(primary_url: str) -> str | None:
    """Return the GNU-tree-relative path (e.g. 'gcc/gcc-16.2.0/gcc-16.2.0.tar.xz').

    ftp.gnu.org URLs are rooted at '/gnu/<path>'; ftpmirror.gnu.org and
    mirrors.kernel.org URLs are rooted at '/<path>' and '/gnu/<path>' respectively.
    Stripping any leading 'gnu/' segment normalizes all three to the same relative
    path, which is what every mirror host expects after its own '/gnu/' prefix.
    """
    hostname = urlparse(primary_url).hostname or ""
    if not any(host in hostname for host in _GNU_HOSTS):
        return None
    path = urlparse(primary_url).path.lstrip("/")
    if path.startswith("gnu/"):
        path = path[len("gnu/") :]
    return path


def _gnu_mirrors(primary_url: str) -> list[str]:
    """Return alternative GNU mirror URLs if primary is a GNU source."""
    rel = _gnu_relative_path(primary_url)
    if rel is None:
        return []
    return [f"{base}{rel}" for base in _GNU_MIRROR_BASES]


def _gnupg_mirrors(primary_url: str) -> list[str]:
    """Return alternative GnuPG download host URLs."""
    parsed = urlparse(primary_url)
    hostname = parsed.hostname or ""
    if hostname not in _GNUPG_HOSTS:
        return []
    path = parsed.path.lstrip("/")
    prefixes = ("ftp/gcrypt/", "gcrypt/")
    prefix = next((x for x in prefixes if path.startswith(x)), None)
    if prefix is None:
        return []
    rel = path[len(prefix) :]
    return [f"{base}{rel}" for base in _GNUPG_MIRROR_BASES]


def _savannah_relative_path(primary_url: str) -> str | None:
    """Return the nongnu-tree-relative path (e.g. 'lzip/lzip-1.26.tar.gz').

    download.savannah.nongnu.org URLs are rooted at '/releases/<path>'; the mirror
    hosts are rooted at '/nongnu/<path>' or '/<path>'. Stripping the leading
    'releases/' segment normalizes to the path every mirror expects.
    """
    hostname = urlparse(primary_url).hostname or ""
    if not any(host in hostname for host in _NONGNU_HOSTS):
        return None
    path = urlparse(primary_url).path.lstrip("/")
    if path.startswith("releases/"):
        path = path[len("releases/") :]
    elif path.startswith("nongnu/"):
        path = path[len("nongnu/") :]
    return path


def _savannah_mirrors(primary_url: str) -> list[str]:
    """Return alternative Savannah mirror URLs if primary is a Savannah source."""
    rel = _savannah_relative_path(primary_url)
    if rel is None:
        return []
    return [f"{base}{rel}" for base in _NONGNU_MIRROR_BASES]


def download_with_mirror(
    primary_url: str,
    name: str,
    filename: str,
    *,
    extra_urls: list[str] | None = None,
    connect_timeout: int = 10,
    max_time: int | None = None,
    speed_limit: int = 1000,
    speed_time: int = 30,
    output: str | None = None,
    quiet: bool = False,
    skip_koopa_mirror: bool = False,
) -> str:
    """Download from primary URL, falling back to mirrors.

    Tries the primary URL first, then the vendor mirror (if configured with
    vendor_first priority), then a vendor remote-proxy rewrite of every
    public URL below (if 'http.remotes' is configured; see
    koopa.vendor.vendor_rewrite_url), then GNU mirrors (if applicable), then
    Savannah mirrors (if applicable), then any extra_urls, then the koopa
    mirror at https://koopa.acidgenomics.com/src/{name}/{filename}.

    When the vendor backend is configured with vendor_only priority, no
    public host is contacted at all: only the vendor mirror and remote-proxy
    rewrites of the URLs above are tried, matching the binary-download path
    in koopa.install.install_app_from_binary_package.

    Uses a short connect_timeout on mirror attempts so broken TLS endpoints
    fail fast instead of blocking for minutes on retries.
    """
    from koopa.vendor import (
        vendor_config,
        vendor_download_src,
        vendor_pull_priority,
        vendor_rewrite_url,
    )

    koopa_mirror = f"https://koopa.acidgenomics.com/src/{name}/{filename}"
    is_archive_payload = filename.lower().endswith(_ARCHIVE_EXTS)
    vendor_url = vendor_download_src(name, filename)
    vendor_only = vendor_config() is not None and vendor_pull_priority() == "vendor_only"

    public = [
        primary_url,
        *_gnu_mirrors(primary_url),
        *_gnupg_mirrors(primary_url),
        *_savannah_mirrors(primary_url),
    ]
    public.extend(extra_urls or [])
    if not skip_koopa_mirror:
        public.append(koopa_mirror)
    rewritten = [u for u in (vendor_rewrite_url(p) for p in public) if u]

    if vendor_only:
        urls = ([vendor_url] if vendor_url else []) + rewritten
        if not urls:
            msg = (
                "vendor_only is configured but no vendor mirror URL is"
                f" available for {name!r} ({filename!r})."
            )
            raise FileNotFoundError(msg)
    else:
        urls = [primary_url]
        if vendor_url:
            urls.append(vendor_url)
        urls.extend(rewritten)
        urls.extend(public[1:])
        # primary_url is now itself one of the GNU/Savannah mirror hosts (e.g.
        # mirrors.kernel.org), so it can reappear as the first entry from
        # _gnu_mirrors()/_savannah_mirrors(), and a rewritten URL can repeat a
        # public one already tried. Dedup, preserving order, so a failed host
        # is not retried immediately with the exact same URL.
        urls = list(dict.fromkeys(urls))

    last_exc: Exception | None = None
    for i, url in enumerate(urls):
        try:
            is_last = i == len(urls) - 1
            tarball = download(
                url,
                output,
                retry=False,
                connect_timeout=connect_timeout if not is_last else None,
                max_time=max_time,
                speed_limit=speed_limit,
                speed_time=speed_time,
                quiet=quiet,
            )
            if is_archive_payload and not archive.is_valid_archive(tarball):
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


@lru_cache(maxsize=4)
def _curl_version(curl_cmd: str = "curl") -> tuple[int, ...]:
    try:
        out = subprocess.run(
            [curl_cmd, "--version"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
        ver_str = out.split()[1]
        return tuple(int(x) for x in ver_str.split(".")[:3])
    except Exception:
        return (0, 0, 0)


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
    speed_limit: int | None = None,
    speed_time: int | None = None,
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
    if speed_limit is not None:
        curl_args.extend(["--speed-limit", str(speed_limit)])
    if speed_time is not None:
        curl_args.extend(["--speed-time", str(speed_time)])
    if retry:
        curl_args.extend(["--retry", "3", "--retry-delay", "5"])
        if _curl_version(curl_cmd) >= (7, 71, 0):
            curl_args.append("--retry-all-errors")
    ca_bundle = os.environ.get("CURL_CA_BUNDLE") or os.environ.get("SSL_CERT_FILE")
    if ca_bundle and os.path.isfile(ca_bundle):
        curl_args.extend(["--cacert", ca_bundle])
    # SourceForge's Cloudflare front 403s this desktop-browser UA string on the
    # files/.../download redirect hop; curl's own default UA is accepted.
    if not _is_sourceforge_url(url):
        curl_args.extend(["--user-agent", _USER_AGENT])
    if os.environ.get("http_proxy") or os.environ.get("https_proxy"):
        curl_args.append("--insecure")
    if os.environ.get("KOOPA_VERBOSE") == "1":
        curl_args.append("--verbose")
    curl_args.append(url)
    if not quiet:
        subprocess.run(curl_args, check=True)
        return
    try:
        subprocess.run(curl_args, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as exc:
        stderr = (exc.stderr or "").strip()
        msg = f"curl exit {exc.returncode}: {stderr}" if stderr else f"curl exit {exc.returncode}"
        raise RuntimeError(msg) from exc


def _download_urllib(url: str, output: str) -> None:
    """Download using urllib."""
    req = urllib.request.Request(url)
    # See _download_curl: SourceForge 403s this UA string.
    if not _is_sourceforge_url(url):
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
