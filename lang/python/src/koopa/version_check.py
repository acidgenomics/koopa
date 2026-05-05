"""Upstream version checking for apps in app.json."""

from __future__ import annotations

import importlib
import inspect
import json
import os
import re
import ssl
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
from collections.abc import Callable
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

from koopa.installers import PYTHON_INSTALLERS
from koopa.io import export_app_json, import_app_json
from koopa.os import os_id
from koopa.prefix import koopa_prefix
from koopa.version import sanitize_version
from koopa.xdg import xdg_cache_home


@dataclass
class VersionCheckResult:
    """Result of checking one app's upstream version."""

    name: str
    current_version: str
    latest_version: str | None
    source: str
    error: str | None = None

    @property
    def is_outdated(self) -> bool:
        """Return whether the latest upstream version is newer than the current pinned version."""
        if self.latest_version is None or self.current_version == self.latest_version:
            return False
        if re.match(r"^[0-9a-f]{40}$", self.latest_version):
            return self.latest_version != self.current_version
        try:
            cur = tuple(
                int(x)
                for x in re.split(r"[.\-]", sanitize_version(self.current_version))
                if x.isdigit()
            )
            lat = tuple(
                int(x)
                for x in re.split(r"[.\-]", sanitize_version(self.latest_version))
                if x.isdigit()
            )
            return lat > cur
        except (ValueError, AttributeError):
            return self.current_version != self.latest_version

    @property
    def is_pinned_too_high(self) -> bool:
        """Return whether the pinned version is higher than the latest stable upstream."""
        if self.latest_version is None or self.current_version == self.latest_version:
            return False
        if re.match(r"^[0-9a-f]{40}$", self.latest_version):
            return False
        try:
            cur = tuple(
                int(x)
                for x in re.split(r"[.\-]", sanitize_version(self.current_version))
                if x.isdigit()
            )
            lat = tuple(
                int(x)
                for x in re.split(r"[.\-]", sanitize_version(self.latest_version))
                if x.isdigit()
            )
            return cur > lat
        except (ValueError, AttributeError):
            return False


class _VersionCache:
    def __init__(self, ttl_hours: int = 24) -> None:
        self._ttl = ttl_hours * 3600
        cache_dir = os.path.join(xdg_cache_home(), "koopa")
        self._path = os.path.join(cache_dir, "version-check.json")
        self._data: dict[str, dict] = {}
        self._load()

    def _load(self) -> None:
        try:
            with open(self._path) as f:
                self._data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError, OSError):
            self._data = {}

    def get(self, name: str) -> str | None:
        entry = self._data.get(name)
        if entry is None:
            return None
        if time.time() - entry.get("ts", 0) > self._ttl:
            return None
        return entry.get("latest_version")

    def put(self, name: str, latest_version: str, source: str) -> None:
        self._data[name] = {
            "latest_version": latest_version,
            "source": source,
            "ts": time.time(),
        }

    def reset(self) -> None:
        self._data = {}

    def save(self) -> None:
        os.makedirs(os.path.dirname(self._path), exist_ok=True)
        with open(self._path, "w") as f:
            json.dump(self._data, f)


class _RateLimiter:
    def __init__(self, requests_per_second: float) -> None:
        self._interval = 1.0 / requests_per_second
        self._last: float = 0.0
        self._lock = threading.Lock()

    def wait(self) -> None:
        with self._lock:
            now = time.monotonic()
            gap = self._interval - (now - self._last)
            self._last = now + max(gap, 0)
        if gap > 0:
            time.sleep(gap)


def _resolve_github_token() -> str | None:
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        return token
    import shutil
    import subprocess

    if shutil.which("gh"):
        try:
            result = subprocess.run(
                ["gh", "auth", "token"],
                capture_output=True,
                text=True,
                timeout=5,
                check=False,
            )
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip()
        except (subprocess.TimeoutExpired, OSError):
            pass
    return None


_github_token: str | None = _resolve_github_token()
_rate_github = _RateLimiter(1.2)
_rate_default = _RateLimiter(5.0)
_ca_bundle = os.environ.get("CURL_CA_BUNDLE") or os.environ.get("SSL_CERT_FILE")
if _ca_bundle and not os.path.isfile(_ca_bundle):
    _ca_bundle = None
_ssl_ctx: ssl.SSLContext | None = (
    ssl.create_default_context(cafile=_ca_bundle) if _ca_bundle else None
)
del _ca_bundle

_INSTALLER_MODULE_RE = re.compile(r"koopa\.installers\.(_\w+)")
_GITHUB_REPO_RE = re.compile(r"github\.com/([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+?)(?:\.git|/|\"|\"|'|$)")
_VERSION_RE = re.compile(r"^\d[\d.\-+a-zA-Z]*$")
_SHA_RE = re.compile(r"^[0-9a-f]{40}$")


def _http_get_json(
    url: str,
    *,
    github: bool = False,
    timeout: int = 15,
) -> Any:  # noqa: ANN401
    limiter = _rate_github if github else _rate_default
    limiter.wait()
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "koopa-version-checker")
    if github:
        req.add_header("Accept", "application/vnd.github+json")
        if _github_token:
            req.add_header("Authorization", f"Bearer {_github_token}")
    with urllib.request.urlopen(req, timeout=timeout, context=_ssl_ctx) as resp:
        return json.loads(resp.read().decode())


def _http_get_text(url: str, *, timeout: int = 15) -> str:
    _rate_default.wait()
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "koopa-version-checker")
    with urllib.request.urlopen(req, timeout=timeout, context=_ssl_ctx) as resp:
        return resp.read().decode()


# ── Individual checkers ───────────────────────────────────────────────


def _sanitize_github_tag(tag: str, repo: str) -> str:
    tag = tag.strip()
    repo_lower = repo.lower().rstrip("/")
    tag_lower = tag.lower()
    for prefix in (
        f"{repo_lower}-",
        f"{repo_lower}_",
        f"{repo_lower}",
        "release-",
        "release_",
    ):
        if tag_lower.startswith(prefix) and len(tag) > len(prefix):
            tag = tag[len(prefix) :]
            break
    tag = tag.replace("_", ".")
    return sanitize_version(tag)


def _check_github(owner: str, repo: str) -> str:
    repo = repo.rstrip("/")
    try:
        data = _http_get_json(
            f"https://api.github.com/repos/{owner}/{repo}/releases/latest",
            github=True,
        )
        tag = data["tag_name"]
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            tags = _http_get_json(
                f"https://api.github.com/repos/{owner}/{repo}/tags?per_page=1",
                github=True,
            )
            if not tags:
                raise
            tag = tags[0]["name"]
        else:
            raise
    return _sanitize_github_tag(tag, repo)


def _check_pypi(package: str) -> str:
    data = _http_get_json(f"https://pypi.org/pypi/{package}/json")
    return data["info"]["version"]


_conda_semaphore = threading.Semaphore(2)


def _conda_exe() -> str | None:
    import shutil

    return os.environ.get("CONDA_EXE") or shutil.which("conda")


def _check_conda(package: str) -> str:
    exe = _conda_exe()
    if exe:
        with _conda_semaphore:
            try:
                result = subprocess.run(
                    [exe, "search", package, "--json"],
                    capture_output=True,
                    text=True,
                    timeout=60,
                    check=False,
                )
            except (subprocess.TimeoutExpired, OSError):
                result = None
        if result is not None and result.returncode == 0:
            try:
                data = json.loads(result.stdout)
                versions = [e["version"] for e in data.get(package, [])]
                if versions:
                    return max(
                        versions,
                        key=lambda v: tuple(int(x) for x in re.split(r"[.\-]", v) if x.isdigit()),
                    )
            except (json.JSONDecodeError, ValueError):
                pass
    msg = f"Cannot determine conda version for {package}: conda CLI unavailable"
    raise RuntimeError(msg)


class _NetworkUnavailableError(RuntimeError):
    """Raised when all network sources for a check are unreachable (e.g. SSL/timeout in corporate env)."""


def _raise_network_unavailable(exc: Exception | None) -> None:
    msg = f"Network unavailable: {exc}"
    raise _NetworkUnavailableError(msg) from exc


def _check_gnu(package: str, *, parent: str = "", non_gnu_mirror: bool = False) -> str:
    name = parent or package
    if non_gnu_mirror:
        bases = [
            f"https://download.savannah.nongnu.org/releases/{name}/",
            f"https://download-mirror.savannah.gnu.org/releases/{name}/",
        ]
    else:
        bases = [
            f"https://mirrors.kernel.org/gnu/{name}/",
            f"https://ftpmirror.gnu.org/gnu/{name}/",
            f"https://ftp.gnu.org/gnu/{name}/",
        ]
    last_exc: Exception | None = None
    html: str | None = None
    for base in bases:
        try:
            html = _http_get_text(base)
            break
        except (urllib.error.URLError, OSError) as exc:
            last_exc = exc
            continue
    if html is None:
        _raise_network_unavailable(last_exc)
        raise AssertionError("unreachable")  # for type checker
    pattern = re.compile(rf"{re.escape(package)}[_-]([\d]+(?:\.[\d]+)*)\.tar\.(?:gz|xz|bz2|lz)")
    versions: list[str] = pattern.findall(html)
    if not versions:
        msg = f"No versions found for GNU {package}"
        raise RuntimeError(msg)
    best = max(versions, key=lambda v: tuple(int(x) for x in v.split(".")))
    return best


def _check_npm(package: str) -> str:
    data = _http_get_json(f"https://registry.npmjs.org/{package}/latest")
    return data["version"]


def _check_crates(crate: str) -> str:
    data = _http_get_json(f"https://crates.io/api/v1/crates/{crate}")
    return data["crate"]["max_stable_version"]


def _check_rubygems(gem: str) -> str:
    data = _http_get_json(f"https://rubygems.org/api/v1/gems/{gem}.json")
    return data["version"]


def _check_metacpan(distribution: str) -> str:
    data = _http_get_json(f"https://fastapi.metacpan.org/v1/release/{distribution}")
    return sanitize_version(data["version"])


def _check_directory_listing(
    url: str,
    tarball_prefix: str,
    *,
    case_sensitive: bool = True,
    timeout: int = 15,
) -> str:
    html = _http_get_text(url, timeout=timeout)
    flags = 0 if case_sensitive else re.IGNORECASE
    pattern = re.compile(
        rf"{re.escape(tarball_prefix)}[_-]([\d]+(?:\.[\d]+)*(?:-\d+)?)"
        rf"(?:\.tar\.(?:gz|xz|bz2|lz)|\.tgz|\.zip)",
        flags,
    )
    versions: list[str] = pattern.findall(html)
    if not versions:
        msg = f"No versions found at {url} for {tarball_prefix}"
        raise RuntimeError(msg)
    best = max(
        set(versions),
        key=lambda v: tuple(int(x) for x in re.split(r"[.\-]", v)),
    )
    return best


def _check_openssl_series(major: str) -> str:
    html = _http_get_text("https://www.openssl.org/source/")
    pattern = re.compile(rf"openssl-({re.escape(major)}\.[\d]+(?:\.[\d]+)*)\.tar")
    versions = pattern.findall(html)
    if not versions:
        msg = f"No OpenSSL {major}.x versions found"
        raise RuntimeError(msg)
    best = max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )
    return best


def _check_directory_version_dirs(url: str, prefix: str = "") -> str:
    html = _http_get_text(url)
    pattern = re.compile(rf">{re.escape(prefix)}([\d]+(?:\.[\d]+)*)/?\s*<")
    versions: list[str] = pattern.findall(html)
    if not versions:
        msg = f"No version directories found at {url}"
        raise RuntimeError(msg)
    best = max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )
    return best


def _check_sourceforge_versions(project_path: str) -> str:
    url = f"https://sourceforge.net/projects/{project_path}"
    html = _http_get_text(url)
    pattern = re.compile(r'title="([\d]+(?:\.[\d]+)+)"')
    versions: list[str] = pattern.findall(html)
    if not versions:
        msg = f"No versions found at {url}"
        raise RuntimeError(msg)
    best = max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )
    return best


def _check_xorg(subdir: str, tarball_prefix: str) -> str:
    url = f"https://xorg.freedesktop.org/archive/individual/{subdir}/"
    try:
        return _check_directory_listing(url, tarball_prefix)
    except (urllib.error.URLError, TimeoutError) as exc:
        msg = f"Network unavailable: {exc}"
        raise _NetworkUnavailableError(msg) from exc


def _check_pkg_config() -> str:
    try:
        return _check_directory_listing("https://pkgconfig.freedesktop.org/releases/", "pkg-config")
    except (urllib.error.URLError, TimeoutError) as exc:
        msg = f"Network unavailable: {exc}"
        raise _NetworkUnavailableError(msg) from exc


def _check_gnupg(package: str) -> str:
    url = f"https://gnupg.org/ftp/gcrypt/{package}/"
    return _check_directory_listing(url, package)


def _check_python_org(minor: str) -> str:
    url = "https://www.python.org/ftp/python/"
    html = _http_get_text(url)
    pattern = re.compile(rf">{minor}\.([\d]+)/")
    patches: list[str] = pattern.findall(html)
    if not patches:
        msg = f"No versions found for Python {minor}"
        raise RuntimeError(msg)
    for patch in sorted(set(int(p) for p in patches), reverse=True):
        version = f"{minor}.{patch}"
        dir_html = _http_get_text(f"{url}{version}/")
        if f"Python-{version}.tar.xz" in dir_html or f"Python-{version}.tgz" in dir_html:
            return version
    msg = f"No stable release found for Python {minor}"
    raise RuntimeError(msg)


def _check_gitlab(domain: str, project_path: str) -> str:
    encoded = project_path.replace("/", "%2F")
    data = _http_get_json(f"https://{domain}/api/v4/projects/{encoded}/releases?per_page=1")
    if not data:
        data = _http_get_json(
            f"https://{domain}/api/v4/projects/{encoded}/repository/tags?per_page=1"
        )
        if not data:
            msg = f"No releases/tags for {project_path} on {domain}"
            raise RuntimeError(msg)
        tag = data[0]["name"]
    else:
        tag = data[0].get("tag_name", data[0].get("name", ""))
    return sanitize_version(tag)


# ── Installer source file GitHub repo extraction ──────────────────────

_installer_github_cache: dict[str, str | None] = {}


def _extract_github_repo_from_installer(module_path: str) -> str | None:
    if module_path in _installer_github_cache:
        return _installer_github_cache[module_path]
    result = None
    try:
        mod = importlib.import_module(module_path)
        source_file = inspect.getfile(mod)
        source = Path(source_file).read_text()
        match = _GITHUB_REPO_RE.search(source)
        if match:
            result = match.group(1)
    except Exception:
        pass
    _installer_github_cache[module_path] = result
    return result


def _extract_github_repo_from_urls(urls: list[str]) -> str | None:
    for url in urls:
        match = re.match(
            r"https?://github\.com/([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+?)(?:\.git|/|$)",
            url,
        )
        if match:
            return match.group(1)
    return None


# ── Classification ────────────────────────────────────────────────────

_GENERIC_INSTALLER_MAP: dict[str, str] = {
    "._conda": "conda",
    "._python_pkg": "pypi",
    "._gnu": "gnu",
    "._node_pkg": "npm",
    "._rust_pkg": "crates",
    "._ruby_pkg": "rubygems",
    "._perl_pkg": "metacpan",
    "._haskell_pkg": "hackage",
}


@dataclass
class _AppCheckSpec:
    source: str
    check_fn: Callable[..., str]
    args: tuple
    batch_size: int | None = None


def classify_app(name: str, info: dict) -> _AppCheckSpec | None:  # noqa: PLR0911
    """Classify an app into a version-check strategy."""
    module_path = PYTHON_INSTALLERS.get(name, "")
    args = info.get("installer_args", {})
    urls = info.get("url", [])
    version = info.get("version", "")
    spec = _SPECIAL_CASES.get(name)
    if spec is not None:
        return spec
    if name == "oracle-instant-client" and version:
        return _AppCheckSpec(
            "dirlist",
            lambda v=version: _check_oracle_instant_client(v),
            (),
        )
    if len(version) == 40:
        return None
    for suffix, source in _GENERIC_INSTALLER_MAP.items():
        if module_path.endswith(suffix):
            result = _classify_generic(source, name, info, args, urls)
            if result is not None:
                return result
            break
    if module_path:
        gh_repo = _extract_github_repo_from_installer(module_path)
        if gh_repo:
            owner, repo = gh_repo.split("/", 1)
            return _AppCheckSpec("github", _check_github, (owner, repo))
    gh_repo = _extract_github_repo_from_urls(urls)
    if gh_repo:
        owner, repo = gh_repo.split("/", 1)
        return _AppCheckSpec("github", _check_github, (owner, repo))
    spec = _classify_by_known_pattern(name, info, module_path, urls)
    if spec:
        return spec
    return None


# ── X.org tarball prefix mapping ──────────────────────────────────────

_XORG_MAP: dict[str, tuple[str, str]] = {
    "xorg-libice": ("lib", "libICE"),
    "xorg-libpthread-stubs": ("lib", "libpthread-stubs"),
    "xorg-libsm": ("lib", "libSM"),
    "xorg-libx11": ("lib", "libX11"),
    "xorg-libxau": ("lib", "libXau"),
    "xorg-libxcb": ("lib", "libxcb"),
    "xorg-libxdmcp": ("lib", "libXdmcp"),
    "xorg-libxext": ("lib", "libXext"),
    "xorg-libxrandr": ("lib", "libXrandr"),
    "xorg-libxrender": ("lib", "libXrender"),
    "xorg-libxt": ("lib", "libXt"),
    "xorg-xcb-proto": ("proto", "xcb-proto"),
    "xorg-xorgproto": ("proto", "xorgproto"),
    "xorg-xtrans": ("lib", "xtrans"),
}

# ── GnuPG ecosystem package names ────────────────────────────────────

_GNUPG_NAMES: dict[str, str] = {
    "gnupg": "gnupg",
    "libassuan": "libassuan",
    "libgcrypt": "libgcrypt",
    "libgpg-error": "libgpg-error",
    "libksba": "libksba",
    "npth": "npth",
    "pinentry": "pinentry",
}

# ── GitLab project mappings ──────────────────────────────────────────

_GITLAB_MAP: dict[str, tuple[str, str]] = {
    "cairo": ("gitlab.freedesktop.org", "cairo/cairo"),
    "glib": ("gitlab.gnome.org", "GNOME/glib"),
    "graphviz": ("gitlab.com", "graphviz/graphviz"),
    "libpipeline": ("gitlab.com", "libpipeline/libpipeline"),
    "libxml2": ("gitlab.gnome.org", "GNOME/libxml2"),
    "libxslt": ("gitlab.gnome.org", "GNOME/libxslt"),
    "man-db": ("gitlab.com", "man-db/man-db"),
}

# ── Directory listing mappings for miscellaneous apps ────────────────
# (url, tarball_prefix)

_DIR_LISTING_MAP: dict[str, tuple[str, str]] = {
    "apr": (
        "https://archive.apache.org/dist/apr/",
        "apr",
    ),
    "armadillo": (
        "https://sourceforge.net/projects/arma/files/",
        "armadillo",
    ),
    "apr-util": (
        "https://archive.apache.org/dist/apr/",
        "apr-util",
    ),
    "bzip2": (
        "https://sourceware.org/pub/bzip2/",
        "bzip2",
    ),
    "convmv": (
        "https://www.j3e.de/linux/convmv/",
        "convmv",
    ),
    "flac": (
        "https://downloads.xiph.org/releases/flac/",
        "flac",
    ),
    "fontconfig": (
        "https://www.freedesktop.org/software/fontconfig/release/",
        "fontconfig",
    ),
    "gmp": (
        "https://gmplib.org/download/gmp/",
        "gmp",
    ),
    "gnutls": (
        "https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/",
        "gnutls",
    ),
    "isl": (
        "https://libisl.sourceforge.io/",
        "isl",
    ),
    "ldns": (
        "https://nlnetlabs.nl/downloads/ldns/",
        "ldns",
    ),
    "libarchive": (
        "https://www.libarchive.org/downloads/",
        "libarchive",
    ),
    "libpcap": (
        "https://www.tcpdump.org/release/",
        "libpcap",
    ),
    "libssh2": (
        "https://www.libssh2.org/download/",
        "libssh2",
    ),
    "libtermkey": (
        "https://www.leonerd.org.uk/code/libtermkey/",
        "libtermkey",
    ),
    "libtiff": (
        "https://download.osgeo.org/libtiff/",
        "tiff",
    ),
    "lzo": (
        "https://www.oberhumer.com/opensource/lzo/download/",
        "lzo",
    ),
    "ncurses": (
        "https://mirrors.kernel.org/gnu/ncurses/",
        "ncurses",
    ),
    "nmap": (
        "https://nmap.org/dist/",
        "nmap",
    ),
    "pcre": (
        "https://sourceforge.net/projects/pcre/files/pcre/",
        "pcre",
    ),
    "pigz": (
        "https://zlib.net/pigz/",
        "pigz",
    ),
    "pixman": (
        "https://cairographics.org/releases/",
        "pixman",
    ),
    "pkg-config": (
        "https://pkgconfig.freedesktop.org/releases/",
        "pkg-config",
    ),
    # NOTE: pkg-config is overridden in _SPECIAL_CASES to handle SSL failures gracefully.
    "rsync": (
        "https://download.samba.org/pub/rsync/src/",
        "rsync",
    ),
    "serf": (
        "https://archive.apache.org/dist/serf/",
        "serf",
    ),
    "subversion": (
        "https://archive.apache.org/dist/subversion/",
        "subversion",
    ),
    "zlib": (
        "https://www.zlib.net/",
        "zlib",
    ),
}


def _classify_by_known_pattern(
    name: str,
    info: dict,
    module_path: str,
    urls: list[str],
) -> _AppCheckSpec | None:
    if name in _XORG_MAP:
        subdir, prefix = _XORG_MAP[name]
        return _AppCheckSpec("xorg", _check_xorg, (subdir, prefix))
    if name in _GNUPG_NAMES:
        pkg = _GNUPG_NAMES[name]
        return _AppCheckSpec("gnupg", _check_gnupg, (pkg,))
    if name in _GITLAB_MAP:
        domain, project = _GITLAB_MAP[name]
        return _AppCheckSpec("gitlab", _check_gitlab, (domain, project))
    m = re.match(r"python(\d+\.\d+)$", name)
    if m:
        minor = m.group(1)
        return _AppCheckSpec("python.org", _check_python_org, (minor,))
    if name in _DIR_LISTING_MAP:
        url, prefix = _DIR_LISTING_MAP[name]
        return _AppCheckSpec(
            "dirlist",
            lambda u=url, p=prefix: _check_directory_listing(u, p),
            (),
        )
    return None


def _check_elfutils() -> str:
    html = _http_get_text("https://sourceware.org/elfutils/ftp/")
    versions = re.findall(r'href="(0\.\d+)/"', html)
    if not versions:
        msg = "No elfutils version directories found"
        raise RuntimeError(msg)
    return max(set(versions), key=lambda v: tuple(int(x) for x in v.split(".")))


def _check_expat() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/libexpat/libexpat/releases/latest",
        github=True,
    )
    tag = data["tag_name"]
    tag = re.sub(r"^R[_.]?", "", tag)
    return tag.replace("_", ".")


def _check_ghostscript() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/ArtifexSoftware/ghostpdl-downloads/releases/latest",
        github=True,
    )
    tag = data["tag_name"]
    m = re.match(r"gs(\d+)", tag)
    if not m:
        msg = f"Cannot parse ghostscript tag: {tag}"
        raise RuntimeError(msg)
    digits = m.group(1)
    if len(digits) == 4:
        major = digits[:2].lstrip("0") or "0"
        minor = digits[2:].lstrip("0") or "0"
        return f"{major}.{minor}"
    if len(digits) == 5:
        major = digits[:2].lstrip("0") or "0"
        minor = digits[2:4].lstrip("0") or "0"
        patch = digits[4:].lstrip("0") or "0"
        return f"{major}.{minor}.{patch}"
    return sanitize_version(digits)


def _check_ca_certificates() -> str:
    html = _http_get_text("https://curl.se/docs/caextract.html")
    dates = re.findall(r"cacert-(\d{4}-\d{2}-\d{2})", html)
    if not dates:
        msg = "No ca-certificates versions found"
        raise RuntimeError(msg)
    return max(dates)


def _check_libedit() -> str:
    html = _http_get_text("https://thrysoee.dk/editline/")
    versions = re.findall(r"libedit-(\d{8}-\d+\.\d+)", html)
    if not versions:
        msg = "No libedit versions found"
        raise RuntimeError(msg)
    return max(versions)


def _check_mpdecimal() -> str:
    html = _http_get_text("https://www.bytereef.org/mpdecimal/download.html")
    versions = re.findall(r"mpdecimal-([\d]+(?:\.[\d]+)*)", html)
    if not versions:
        msg = "No mpdecimal versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_llvm() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/llvm/llvm-project/releases/latest",
        github=True,
    )
    tag = data["tag_name"]
    m = re.match(r"llvmorg-([\d]+(?:\.[\d]+)*)", tag)
    if not m:
        msg = f"Cannot parse LLVM tag: {tag}"
        raise RuntimeError(msg)
    return m.group(1)


def _check_libsolv() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/openSUSE/libsolv/tags?per_page=20",
        github=True,
    )
    versions: list[str] = []
    for tag in data:
        m = re.match(r"([\d]+(?:\.[\d]+)+)$", tag["name"])
        if m:
            versions.append(m.group(1))
    if not versions:
        msg = "No libsolv version tags found"
        raise RuntimeError(msg)
    return max(
        versions,
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_msgpack() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/msgpack/msgpack-c/releases/latest",
        github=True,
    )
    tag = data["tag_name"]
    m = re.match(r"c(?:pp)?-([\d]+(?:\.[\d]+)*)", tag)
    if not m:
        msg = f"Cannot parse msgpack tag: {tag}"
        raise RuntimeError(msg)
    return m.group(1)


def _check_openssh() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/openssh/openssh-portable/tags?per_page=10",
        github=True,
    )
    for tag in data:
        m = re.match(r"V_(\d+)_(\d+)(?:_P(\d+))?$", tag["name"])
        if m:
            major, minor = m.group(1), m.group(2)
            portable = m.group(3) or ""
            suffix = f"p{portable}" if portable else ""
            return f"{major}.{minor}{suffix}"
    msg = "No openssh version tags found"
    raise RuntimeError(msg)


def _check_staden_io_lib() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/jkbonfield/io_lib/releases/latest",
        github=True,
    )
    tag = data["tag_name"]
    m = re.match(r"io_lib-([\d]+(?:-[\d]+)*)", tag)
    if not m:
        msg = f"Cannot parse staden-io-lib tag: {tag}"
        raise RuntimeError(msg)
    return m.group(1).replace("-", ".")


def _check_temurin() -> str:
    info = _http_get_json("https://api.adoptium.net/v3/info/available_releases")
    lts = info.get("most_recent_lts")
    if not lts:
        msg = "Cannot determine most recent Temurin LTS"
        raise RuntimeError(msg)
    data = _http_get_json(
        "https://api.adoptium.net/v3/info/release_names"
        "?heap_size=normal&image_type=jdk"
        "&os=linux&page=0&page_size=1"
        "&project=jdk&release_type=ga"
        "&semver=false&sort_method=DEFAULT"
        "&sort_order=DESC&vendor=eclipse"
        f"&version=%5B{lts}%2C{lts + 1})"
    )
    if not data.get("releases"):
        msg = f"No Temurin JDK {lts} releases found"
        raise RuntimeError(msg)
    tag = data["releases"][0]
    m = re.match(r"jdk-(\d+(?:\.\d+)*(?:\+\d+)?)", tag)
    if not m:
        msg = f"Cannot parse Temurin tag: {tag}"
        raise RuntimeError(msg)
    return m.group(1)


def _check_liblinear() -> str:
    _rate_default.wait()
    req = urllib.request.Request("https://www.csie.ntu.edu.tw/~cjlin/liblinear/")
    req.add_header("User-Agent", "koopa-version-checker")
    with urllib.request.urlopen(req, timeout=15) as resp:
        html = resp.read().decode("latin-1")
    m = re.search(r"Version\s+(\d+\.\d+)", html)
    if not m:
        msg = "No liblinear version found"
        raise RuntimeError(msg)
    return m.group(1)


def _check_github_head(owner: str, repo: str) -> str:
    for branch in ("main", "master"):
        try:
            data = _http_get_json(
                f"https://api.github.com/repos/{owner}/{repo}/commits/{branch}",
                github=True,
            )
            return data["sha"]
        except urllib.error.HTTPError:
            continue
    msg = f"Cannot determine HEAD for {owner}/{repo}"
    raise RuntimeError(msg)


def _check_anaconda() -> str:
    html = _http_get_text("https://repo.anaconda.com/archive/")
    versions = re.findall(r"Anaconda3-(\d{4}\.\d+(?:-\d+)?)-", html)
    if not versions:
        msg = "No Anaconda versions found"
        raise RuntimeError(msg)
    return max(set(versions))


def _check_apache_dirlist(project: str) -> str:
    url = f"https://archive.apache.org/dist/{project}/"
    html = _http_get_text(url)
    pattern = re.compile(rf"{re.escape(project)}-([\d]+(?:\.[\d]+)*)")
    versions = pattern.findall(html)
    if not versions:
        msg = f"No versions found for Apache {project}"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_dash() -> str:
    html = _http_get_text("https://git.kernel.org/pub/scm/utils/dash/dash.git/refs/tags")
    versions = re.findall(r">v([\d]+\.[\d]+(?:\.[\d]+)*)<", html)
    if not versions:
        msg = "No dash versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_ensembl() -> str:
    page = 1
    best = 0
    while True:
        data = _http_get_json(
            f"https://api.github.com/repos/Ensembl/ensembl/branches?per_page=100&page={page}",
            github=True,
        )
        if not data:
            break
        for b in data:
            m = re.match(r"release/(\d+)$", b["name"])
            if m:
                best = max(best, int(m.group(1)))
        page += 1
    if not best:
        msg = "No Ensembl release branches found"
        raise RuntimeError(msg)
    return str(best)


def _check_fltk() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/fltk/fltk/releases/latest",
        github=True,
    )
    tag = data["tag_name"]
    m = re.match(r"release-([\d]+(?:\.[\d]+)*)", tag)
    if not m:
        msg = f"Cannot parse FLTK tag: {tag}"
        raise RuntimeError(msg)
    return m.group(1)


def _check_jpeg() -> str:
    _rate_default.wait()
    req = urllib.request.Request("https://www.ijg.org/files/")
    req.add_header("User-Agent", "koopa-version-checker")
    with urllib.request.urlopen(req, timeout=15) as resp:
        html = resp.read().decode("latin-1")
    versions = re.findall(r"jpegsrc\.v(\d+[a-z]?)\.tar", html)
    if not versions:
        msg = "No JPEG versions found"
        raise RuntimeError(msg)
    return max(versions)


def _check_krb5() -> str:
    html = _http_get_text("https://kerberos.org/dist/krb5/")
    dirs = re.findall(r"href=\"([\d]+\.[\d]+)/?\"", html)
    if not dirs:
        msg = "No krb5 version directories found"
        raise RuntimeError(msg)
    latest_dir = max(
        set(dirs),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )
    html2 = _http_get_text(f"https://kerberos.org/dist/krb5/{latest_dir}/")
    versions = re.findall(r"krb5-([\d]+(?:\.[\d]+)*)\.tar", html2)
    if not versions:
        msg = f"No krb5 tarballs found in {latest_dir}"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_sqlite() -> str:
    html = _http_get_text("https://www.sqlite.org/download.html")
    fvs = re.findall(r"sqlite-autoconf-(\d{7,})\.tar", html)
    if not fvs:
        msg = "No SQLite versions found"
        raise RuntimeError(msg)
    fv = max(set(fvs))
    major = fv[0]
    minor = str(int(fv[1:3]))
    patch = str(int(fv[3:5]))
    return f"{major}.{minor}.{patch}"


def _check_perl() -> str:
    html = _http_get_text("https://www.cpan.org/src/5.0/")
    pattern = re.compile(r"perl-([\d]+(?:\.[\d]+)*)\.tar\.(?:gz|xz|bz2)")
    versions = pattern.findall(html)
    if not versions:
        msg = "No Perl versions found"
        raise RuntimeError(msg)
    stable = [v for v in versions if int(v.split(".")[1]) % 2 == 0]
    if not stable:
        msg = "No stable Perl versions found"
        raise RuntimeError(msg)
    return max(
        set(stable),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_r_devel() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/r-devel/r-svn/commits?sha=trunk&per_page=1",
        github=True,
    )
    msg_text = data[0]["commit"]["message"]
    m = re.search(r"git-svn-id:.*@(\d+)", msg_text)
    if not m:
        msg = "Cannot determine R-devel SVN revision"
        raise RuntimeError(msg)
    return m.group(1)


def _check_rstudio_server() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/rstudio/rstudio/tags?per_page=1",
        github=True,
    )
    if not data:
        msg = "No rstudio-server tags found"
        raise RuntimeError(msg)
    tag = data[0]["name"]
    tag = tag.lstrip("vV")
    return tag.replace("+", "-")


def _check_r_gfortran() -> str:
    html = _http_get_text("https://mac.r-project.org/tools/")
    versions = re.findall(r"gfortran-(\d+\.\d+)-universal", html)
    if not versions:
        msg = "No r-gfortran versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_r_xcode_openmp() -> str:
    html = _http_get_text("https://mac.r-project.org/openmp/")
    versions = re.findall(r"openmp-(\d+(?:\.\d+)*)-darwin", html)
    if not versions:
        msg = "No r-xcode-openmp versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_ont_guppy() -> str:
    html = _http_get_text(
        "https://nanoporetech.com/software/other/guppy/history",
        timeout=30,
    )
    versions = re.findall(r'"(\d+\.\d+\.\d+)"', html)
    versions = [v for v in versions if not v.startswith(("44", "26"))]
    if not versions:
        msg = "No ONT Guppy versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_aspera_connect() -> str:
    html = _http_get_text(
        "https://www.ibm.com/products/aspera/downloads",
        timeout=30,
    )
    versions = re.findall(r"aspera-connect_(\d+\.\d+\.\d+\.\d+)", html)
    if not versions:
        msg = "No Aspera Connect versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_illumina_ica_cli() -> str:
    html = _http_get_text(
        "https://help.ica.illumina.com/reference/software-release-notes",
        timeout=30,
    )
    versions = re.findall(r"ICA v(\d+\.\d+\.\d+)", html)
    if not versions:
        msg = "No Illumina ICA CLI versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )


def _check_miniconda() -> str:
    html = _http_get_text("https://repo.anaconda.com/miniconda/")
    versions = re.findall(r"Miniconda3-py\d+_(\d+\.\d+\.\d+-\d+)-", html)
    if not versions:
        msg = "No Miniconda versions found"
        raise RuntimeError(msg)
    return max(
        set(versions),
        key=lambda v: tuple(int(x) for x in re.split(r"[.\-]", v)),
    )


def _check_oracle_instant_client(current_version: str) -> str:
    major = current_version.split(".", maxsplit=1)[0]
    html = _http_get_text(
        "https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html",
        timeout=30,
    )
    versions = re.findall(r"Version\s+(\d+(?:\.\d+)+)", html)
    if not versions:
        msg = "No Oracle Instant Client versions found"
        raise RuntimeError(msg)
    matched = [v for v in versions if v.startswith(f"{major}.")]
    if not matched:
        msg = f"No Oracle Instant Client {major}.x versions found"
        raise RuntimeError(msg)
    best = max(
        set(matched),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )
    return f"{best}-1"


def _make_dirlist_spec(url: str, prefix: str) -> _AppCheckSpec:
    return _AppCheckSpec(
        "dirlist",
        lambda u=url, p=prefix: _check_directory_version_dirs(u, p),
        (),
    )


def _make_openssl_spec(major: str) -> _AppCheckSpec:
    return _AppCheckSpec("dirlist", lambda m=major: _check_openssl_series(m), ())


def _apply_batch_version(latest: str, current: str, batch_size: int) -> str:
    """Floor latest version's patch component to the nearest batch boundary.

    Returns the floored version if it is strictly greater than the current
    version, otherwise returns the current version (no-op / no downgrade).
    """

    def _parts(v: str) -> tuple[int, ...]:
        return tuple(int(x) for x in v.split("."))

    m = re.match(r"^(\d+\.\d+\.)(\d+)$", latest)
    if m:
        prefix = m.group(1)
        patch = int(m.group(2))
        floored_patch = (patch // batch_size) * batch_size
        floored = f"{prefix}{floored_patch:04d}"
        if _parts(floored) <= _parts(current):
            return current
        return floored
    m = re.match(r"^(\d+)$", latest)
    if m:
        floored = str((int(latest) // batch_size) * batch_size)
        if _parts(floored) <= _parts(current):
            return current
        return floored
    return latest


def _check_freetype() -> str:
    tags = _http_get_json(
        "https://api.github.com/repos/freetype/freetype/tags?per_page=100",
        github=True,
    )
    versions: list[str] = []
    for tag in tags:
        m = re.match(r"VER-(\d+)-(\d+)-(\d+)$", tag["name"])
        if m:
            versions.append(f"{m.group(1)}.{m.group(2)}.{m.group(3)}")
    if not versions:
        msg = "No freetype version tags found"
        raise RuntimeError(msg)
    return max(versions, key=lambda v: tuple(int(x) for x in v.split(".")))


def _check_boost() -> str:
    data = _http_get_json(
        "https://api.github.com/repos/boostorg/boost/releases/latest",
        github=True,
    )
    tag = data["tag_name"]
    return re.sub(r"^boost-", "", tag)


_SPECIAL_CASES: dict[str, _AppCheckSpec] = {
    "google-cloud-sdk": _AppCheckSpec("conda", _check_conda, ("google-cloud-sdk",)),
    "libtool": _AppCheckSpec("gnu", lambda: _check_gnu("libtool"), ()),
    "tar": _AppCheckSpec("gnu", lambda: _check_gnu("tar"), ()),
    "aws-cli": _AppCheckSpec("conda", _check_conda, ("awscli",)),
    "vim": _AppCheckSpec("github", _check_github, ("vim", "vim"), batch_size=100),
    "boost": _AppCheckSpec("github", _check_boost, ()),
    "bash": _AppCheckSpec(
        "gnu",
        lambda: _check_gnu("bash"),
        (),
    ),
    "ca-certificates": _AppCheckSpec("dirlist", _check_ca_certificates, ()),
    "elfutils": _AppCheckSpec(
        "dirlist",
        _check_elfutils,
        (),
    ),
    "expat": _AppCheckSpec("github", _check_expat, ()),
    "gcc": _make_dirlist_spec("https://mirrors.kernel.org/gnu/gcc/", "gcc-"),
    "ghostscript": _AppCheckSpec("github", _check_ghostscript, ()),
    "git": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "https://mirrors.edge.kernel.org/pub/software/scm/git/",
            "git",
        ),
        (),
    ),
    "go": _make_dirlist_spec("https://go.dev/dl/", "go"),
    "imagemagick": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "https://imagemagick.org/archive/releases/",
            "ImageMagick",
        ),
        (),
    ),
    "hadolint": _AppCheckSpec("github", _check_github, ("hadolint", "hadolint")),
    "libedit": _AppCheckSpec("dirlist", _check_libedit, ()),
    "libidn": _AppCheckSpec(
        "gnu",
        lambda: _check_gnu("libidn2", parent="libidn"),
        (),
    ),
    "libpng": _AppCheckSpec(
        "dirlist",
        lambda: _check_sourceforge_versions("libpng/files/libpng16/"),
        (),
    ),
    "nano": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "https://www.nano-editor.org/dist/latest/",
            "nano",
        ),
        (),
    ),
    "openssl3": _make_openssl_spec("3"),
    "perl": _AppCheckSpec("dirlist", _check_perl, ()),
    "postgresql": _make_dirlist_spec("https://ftp.postgresql.org/pub/source/", "v"),
    "r": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "https://cloud.r-project.org/src/base/R-4/",
            "R",
        ),
        (),
    ),
    "ruby": _AppCheckSpec("github", _check_github, ("ruby", "ruby")),
    "rust": _AppCheckSpec("github", _check_github, ("rust-lang", "rust")),
    "pkg-config": _AppCheckSpec("dirlist", _check_pkg_config, ()),
    "screen": _AppCheckSpec(
        "gnu",
        lambda: _check_gnu("screen"),
        (),
    ),
    "swig": _AppCheckSpec("github", _check_github, ("swig", "swig")),
    "tcl-tk": _AppCheckSpec(
        "dirlist",
        lambda: _check_sourceforge_versions("tcl/files/Tcl/"),
        (),
    ),
    "liblinear": _AppCheckSpec("github", _check_liblinear, ()),
    "libheif": _AppCheckSpec("github", _check_github, ("strukturag", "libheif")),
    "libsolv": _AppCheckSpec("github", _check_libsolv, ()),
    "llvm": _AppCheckSpec("github", _check_llvm, ()),
    "mpdecimal": _AppCheckSpec("dirlist", _check_mpdecimal, ()),
    "msgpack": _AppCheckSpec("github", _check_msgpack, ()),
    "openjpeg": _AppCheckSpec("github", _check_github, ("uclouvain", "openjpeg")),
    "openssh": _AppCheckSpec("github", _check_openssh, ()),
    "r-devel": _AppCheckSpec("svn", _check_r_devel, (), batch_size=100),
    "staden-io-lib": _AppCheckSpec("github", _check_staden_io_lib, ()),
    "taglib": _AppCheckSpec("github", _check_github, ("taglib", "taglib")),
    "temurin": _AppCheckSpec("adoptium", _check_temurin, ()),
    "uv": _AppCheckSpec("pypi", _check_pypi, ("uv",)),
    "wget2": _AppCheckSpec(
        "gnu",
        lambda: _check_gnu("wget2", parent="wget"),
        (),
    ),
    "woff2": _AppCheckSpec("github", _check_github, ("google", "woff2")),
    "anaconda": _AppCheckSpec("dirlist", _check_anaconda, ()),
    "apache-arrow": _AppCheckSpec(
        "github",
        lambda: _sanitize_github_tag(
            _http_get_json(
                "https://api.github.com/repos/apache/arrow/releases/latest",
                github=True,
            )["tag_name"],
            "apache-arrow",
        ),
        (),
    ),
    "apache-spark": _AppCheckSpec(
        "dirlist",
        lambda: _check_apache_dirlist("spark"),
        (),
    ),
    "bfg": _AppCheckSpec("github", _check_github, ("rtyley", "bfg-repo-cleaner")),
    "cloudbiolinux": _AppCheckSpec(
        "github",
        lambda: _check_github_head("chapmanb", "cloudbiolinux"),
        (),
    ),
    "conda": _AppCheckSpec("dirlist", _check_miniconda, ()),
    "dash": _AppCheckSpec("dirlist", _check_dash, ()),
    "doom-emacs": _AppCheckSpec(
        "github",
        lambda: _check_github_head("doomemacs", "doomemacs"),
        (),
    ),
    "dotfiles": _AppCheckSpec(
        "github",
        lambda: _check_github_head("acidgenomics", "dotfiles"),
        (),
    ),
    "ensembl-perl-api": _AppCheckSpec("github", _check_ensembl, ()),
    "fltk": _AppCheckSpec("github", _check_fltk, ()),
    "freetype": _AppCheckSpec("github", _check_freetype, ()),
    "haskell-cabal": _AppCheckSpec(
        "github",
        lambda: _sanitize_github_tag(
            _http_get_json(
                "https://api.github.com/repos/haskell/cabal/releases/latest",
                github=True,
            )["tag_name"],
            "cabal-install",
        ),
        (),
    ),
    "jpeg": _AppCheckSpec("dirlist", _check_jpeg, ()),
    "krb5": _AppCheckSpec("dirlist", _check_krb5, ()),
    "lame": _AppCheckSpec(
        "dirlist",
        lambda: _check_sourceforge_versions("lame/files/lame/"),
        (),
    ),
    "libev": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "http://dist.schmorp.de/libev/",
            "libev",
        ),
        (),
    ),
    "libvterm": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "https://www.leonerd.org.uk/code/libvterm/",
            "libvterm",
        ),
        (),
    ),
    "luajit": _AppCheckSpec(
        "github",
        lambda: _check_github_head("LuaJIT", "LuaJIT"),
        (),
    ),
    "nim": _AppCheckSpec("github", _check_github, ("nim-lang", "Nim")),
    "openldap": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "https://www.openldap.org/software/download/OpenLDAP/openldap-release/",
            "openldap",
        ),
        (),
    ),
    "password-store": _AppCheckSpec("github", _check_github, ("zx2c4", "password-store")),
    "pbzip2": _AppCheckSpec(
        "dirlist",
        lambda: _check_directory_listing(
            "https://launchpad.net/pbzip2/+download",
            "pbzip2",
            timeout=30,
        ),
        (),
    ),
    "prelude-emacs": _AppCheckSpec(
        "github",
        lambda: _check_github_head("bbatsov", "prelude"),
        (),
    ),
    "readline": _AppCheckSpec(
        "gnu",
        lambda: _check_gnu("readline"),
        (),
    ),
    "spacemacs": _AppCheckSpec(
        "github",
        lambda: _check_github_head("syl20bnr", "spacemacs"),
        (),
    ),
    "spacevim": _AppCheckSpec(
        "github",
        lambda: _check_github_head("SpaceVim", "SpaceVim"),
        (),
    ),
    "sqlite": _AppCheckSpec("dirlist", _check_sqlite, ()),
    "udunits": _AppCheckSpec("github", _check_github, ("Unidata", "UDUNITS-2")),
    "aspera-connect": _AppCheckSpec("dirlist", _check_aspera_connect, ()),
    "autodock-adfr": _AppCheckSpec(
        "dirlist",
        lambda: "1.0",
        (),
    ),
    "bcl2fastq": _AppCheckSpec(
        "dirlist",
        lambda: "2.20",
        (),
    ),
    "illumina-ica-cli": _AppCheckSpec("dirlist", _check_illumina_ica_cli, ()),
    "pkgconf": _AppCheckSpec(
        "github",
        lambda: _sanitize_github_tag(
            _http_get_json(
                "https://api.github.com/repos/pkgconf/pkgconf/tags?per_page=1",
                github=True,
            )[0]["name"],
            "pkgconf",
        ),
        (),
    ),
    "ont-guppy": _AppCheckSpec("dirlist", _check_ont_guppy, ()),
    "cellranger": _AppCheckSpec("github", _check_github, ("10XGenomics", "cellranger")),
    "r-gfortran": _AppCheckSpec("dirlist", _check_r_gfortran, ()),
    "r-xcode-openmp": _AppCheckSpec("dirlist", _check_r_xcode_openmp, ()),
    "rstudio-server": _AppCheckSpec("github", _check_rstudio_server, ()),
    "shiny-server": _AppCheckSpec("github", _check_github, ("rstudio", "shiny-server")),
    "unzip": _AppCheckSpec(
        "dirlist",
        lambda: "6.0",
        (),
    ),
    "zip": _AppCheckSpec(
        "dirlist",
        lambda: _check_sourceforge_versions("infozip/files/Zip%203.x%20%28latest%29/"),
        (),
    ),
}


def _classify_generic(  # noqa: PLR0911
    source: str,
    name: str,
    info: dict,
    args: dict,
    urls: list[str],
) -> _AppCheckSpec | None:
    if source == "conda":
        pkg = _get_str(args, "name") or name
        return _AppCheckSpec("conda", _check_conda, (pkg,))
    if source == "pypi":
        pkg = _resolve_pypi_name(name, args, urls)
        return _AppCheckSpec("pypi", _check_pypi, (pkg,))
    if source == "gnu":
        pkg_name = _get_str(args, "package_name") or name
        parent = _get_str(args, "parent_name") or ""
        non_gnu = _get_str(args, "non_gnu_mirror") == "true"
        return _AppCheckSpec(
            "gnu",
            lambda p=pkg_name, pa=parent, ng=non_gnu: _check_gnu(p, parent=pa, non_gnu_mirror=ng),
            (),
        )
    if source == "npm":
        pkg = _get_str(args, "name") or name
        return _AppCheckSpec("npm", _check_npm, (pkg,))
    if source == "crates":
        return _AppCheckSpec("crates", _check_crates, (name,))
    if source == "rubygems":
        return _AppCheckSpec("rubygems", _check_rubygems, (name,))
    if source == "metacpan":
        cpan_path = _get_str(args, "cpan_path")
        if cpan_path:
            dist = cpan_path.split("/")[-1]
            return _AppCheckSpec("metacpan", _check_metacpan, (dist,))
        return None
    return None


def _get_str(d: dict, key: str) -> str:
    val = d.get(key, "")
    if isinstance(val, list):
        return val[0] if val else ""
    return val


def _infer_conda_channel(urls: list[str]) -> str:
    for url in urls:
        if "bioconda" in url:
            return "bioconda"
    return "conda-forge"


def _resolve_pypi_name(name: str, args: dict, urls: list[str]) -> str:
    pip_name = _get_str(args, "pip_name")
    if pip_name:
        return re.sub(r"\[.*\]", "", pip_name)
    egg_name = _get_str(args, "egg_name")
    if egg_name:
        return egg_name.replace("_", "-")
    for url in urls:
        m = re.search(r"pypi\.org/project/([^/]+)", url)
        if m:
            return m.group(1)
    return name


# ── Orchestrator ──────────────────────────────────────────────────────


def check_app_versions(
    *,
    source_filter: str | None = None,
    name_filter: list[str] | None = None,
    max_workers: int = 16,
    reset_cache: bool = False,
) -> list[VersionCheckResult]:
    """Check upstream versions for all apps in app.json."""
    if _github_token is None:
        msg = (
            "GitHub token is not available."
            "\nChecked: GITHUB_TOKEN, GH_TOKEN, and 'gh auth token'."
            "\nEither set GITHUB_TOKEN or authenticate the GitHub CLI:"
            "\n    gh auth login"
        )
        raise RuntimeError(msg)
    json_data = import_app_json()
    cache = _VersionCache()
    if reset_cache:
        cache.reset()
    specs: list[tuple[str, str, _AppCheckSpec]] = []
    unsupported: list[VersionCheckResult] = []
    platform = os_id()
    for app_name, info in sorted(json_data.items()):
        if name_filter and app_name not in name_filter:
            continue
        if info.get("alias_of"):
            continue
        if info.get("removed", False):
            continue
        if info.get("version_pin", False):
            continue
        version = info.get("version", "")
        if not version:
            unsupported.append(VersionCheckResult(app_name, "", None, "none", "no version"))
            continue
        supported_map = info.get("supported", {})
        if (
            supported_map
            and not supported_map.get(platform, False)
            and info.get("installer") == "conda-package"
        ):
            unsupported.append(
                VersionCheckResult(
                    app_name, version, None, "unsupported", f"not supported on {platform}"
                )
            )
            continue
        spec = classify_app(app_name, info)
        if spec is None:
            unsupported.append(VersionCheckResult(app_name, version, None, "unsupported", None))
            continue
        if source_filter and spec.source != source_filter:
            continue
        specs.append((app_name, version, spec))
    results: list[VersionCheckResult] = list(unsupported)
    if not specs:
        return results
    to_check: list[tuple[str, str, _AppCheckSpec]] = []
    for app_name, version, spec in specs:
        if cache is not None:
            cached = cache.get(app_name)
            if cached is not None:
                if _SHA_RE.match(cached):
                    results.append(VersionCheckResult(app_name, version, cached, spec.source, None))
                    continue
                if _VERSION_RE.match(cached):
                    results.append(VersionCheckResult(app_name, version, cached, spec.source, None))
                    continue
        to_check.append((app_name, version, spec))
    cached_count = len(specs) - len(to_check)
    total = len(to_check)
    if not to_check:
        if cached_count:
            print(
                f"All {cached_count} apps resolved from cache.",
                file=sys.stderr,
            )
        results.sort(key=lambda r: r.name)
        return results

    try:
        from tqdm import tqdm

        desc = "Checking app versions"
        if cached_count:
            desc += f" ({cached_count} cached)"
        pbar = tqdm(total=total, desc=desc, unit="app")
    except ModuleNotFoundError:
        pbar = None
        msg = f"Checking {total} app versions..."
        if cached_count:
            msg += f" ({cached_count} cached)"
        print(msg, file=sys.stderr)

    completed = {"n": 0}
    completed_lock = threading.Lock()

    def _run_check(
        app_name: str, current: str, spec: _AppCheckSpec
    ) -> tuple[VersionCheckResult, str | None]:
        try:
            latest = spec.check_fn(*spec.args)
            if not (_VERSION_RE.match(latest) or _SHA_RE.match(latest)):
                msg = f"Invalid version string for {app_name}: {latest!r}"
                raise RuntimeError(msg)
            if spec.batch_size is not None:
                latest = _apply_batch_version(latest, current, spec.batch_size)
            if cache is not None:
                cache.put(app_name, latest, spec.source)
            current_san = sanitize_version(current)
            latest_san = sanitize_version(latest)
            if current_san == latest_san:
                msg = None
            else:
                try:
                    cur_p = tuple(int(x) for x in re.split(r"[.\-]", current_san) if x.isdigit())
                    lat_p = tuple(int(x) for x in re.split(r"[.\-]", latest_san) if x.isdigit())
                    if lat_p < cur_p:
                        msg = f"{app_name}: {current} pinned too high (latest stable: {latest})"
                    else:
                        msg = f"{app_name}: {current} -> {latest}"
                except (ValueError, AttributeError):
                    msg = f"{app_name}: {current} -> {latest}"
            return VersionCheckResult(app_name, current, latest, spec.source, None), msg
        except _NetworkUnavailableError:
            return VersionCheckResult(app_name, current, current, spec.source, None), None
        except Exception as exc:
            msg = f"{app_name}: error: {exc}"
            return VersionCheckResult(app_name, current, None, spec.source, str(exc)), msg

    with ThreadPoolExecutor(max_workers=max_workers) as pool:
        futures = {
            pool.submit(_run_check, app_name, version, spec): app_name
            for app_name, version, spec in to_check
        }
        for future in as_completed(futures):
            result, msg = future.result()
            results.append(result)
            if pbar is not None:
                if msg:
                    pbar.write(msg, file=sys.stderr)
                pbar.update(1)
            else:
                with completed_lock:
                    completed["n"] += 1
                    n = completed["n"]
                if msg:
                    print(f"  [{n}/{total}] {msg}", file=sys.stderr)
                elif n % 50 == 0 or n == total:
                    print(
                        f"  [{n}/{total}] checked...",
                        file=sys.stderr,
                    )
    if pbar is not None:
        pbar.close()
    if cache is not None:
        cache.save()
    results.sort(key=lambda r: r.name)
    return results


# ── Reporting ─────────────────────────────────────────────────────────


def print_report(results: list[VersionCheckResult]) -> None:
    """Print a human-readable version check report."""
    outdated = [r for r in results if r.is_outdated]
    pinned_too_high = [r for r in results if r.is_pinned_too_high]
    current = [
        r
        for r in results
        if r.latest_version is not None and not r.is_outdated and not r.is_pinned_too_high
    ]
    failed = [r for r in results if r.error is not None and r.source != "unsupported"]
    unsupported = [r for r in results if r.source in ("unsupported", "none")]
    print()
    if outdated:
        print(f"Outdated ({len(outdated)}):")
        name_w = max(len(r.name) for r in outdated)
        cur_w = max(len(r.current_version) for r in outdated)
        for r in sorted(outdated, key=lambda x: x.name):
            print(
                f"  {r.name:<{name_w}}  {r.current_version:>{cur_w}}"
                f"  ->  {r.latest_version}  ({r.source})"
            )
        print()
    if pinned_too_high:
        print(f"Pinned too high ({len(pinned_too_high)}):")
        name_w = max(len(r.name) for r in pinned_too_high)
        cur_w = max(len(r.current_version) for r in pinned_too_high)
        for r in sorted(pinned_too_high, key=lambda x: x.name):
            print(
                f"  {r.name:<{name_w}}  {r.current_version:>{cur_w}}"
                f"  (latest stable: {r.latest_version})  ({r.source})"
            )
        print()
    if failed:
        print(f"Failed ({len(failed)}):")
        for r in sorted(failed, key=lambda x: x.name):
            print(f"  {r.name}: {r.error}")
        print()
    if unsupported:
        print(f"Unsupported ({len(unsupported)}):")
        for r in sorted(unsupported, key=lambda x: x.name):
            print(f"  {r.name}: {r.current_version}")
        print()
    print(f"Up to date: {len(current)}")
    print(f"Outdated: {len(outdated)}")
    print(f"Pinned too high: {len(pinned_too_high)}")
    print(f"Failed: {len(failed)}")
    print(f"Unsupported: {len(unsupported)}")


def print_json_report(results: list[VersionCheckResult]) -> None:
    """Print a JSON-formatted version check report."""
    outdated = [asdict(r) for r in results if r.is_outdated]
    pinned_too_high = [asdict(r) for r in results if r.is_pinned_too_high]
    current = [
        asdict(r)
        for r in results
        if r.latest_version is not None and not r.is_outdated and not r.is_pinned_too_high
    ]
    failed = [asdict(r) for r in results if r.error is not None and r.source != "unsupported"]
    unsupported = [asdict(r) for r in results if r.source in ("unsupported", "none")]
    print(
        json.dumps(
            {
                "outdated": outdated,
                "pinned_too_high": pinned_too_high,
                "up_to_date": current,
                "failed": failed,
                "unsupported": unsupported,
            },
            indent=2,
        )
    )


# ── app.json updater ─────────────────────────────────────────────────


def _has_acidgenomics_aws() -> bool:
    """Return True if the acidgenomics AWS profile is present in ~/.aws/credentials."""
    import re

    credentials = os.path.join(os.path.expanduser("~"), ".aws", "credentials")
    if not os.path.isfile(credentials):
        return False
    with open(credentials) as f:
        return bool(re.search(r"^\[acidgenomics\]$", f.read(), re.MULTILINE))


def _expand_src_url(template: str, version: str) -> str:
    """Expand a src_url template with version components.

    Supports {version}, {major}, {minor}, {patch}, {year}, {file_version}
    placeholders. {year} is the current UTC year. {file_version} is the
    zero-padded concatenation used by SQLite: {major}{minor:02d}{patch:02d}00.
    """
    import datetime

    parts = version.split(".")
    major = parts[0] if len(parts) > 0 else ""
    minor = parts[1] if len(parts) > 1 else ""
    patch = parts[2] if len(parts) > 2 else ""
    try:
        file_version = f"{major}{int(minor):02d}{int(patch):02d}00"
    except ValueError:
        file_version = ""
    year = str(datetime.datetime.now(tz=datetime.UTC).year)
    return template.format(
        version=version,
        major=major,
        minor=minor,
        patch=patch,
        year=year,
        file_version=file_version,
    )


def _mirror_src_to_s3(
    name: str, version: str, src_url_template: str, *, strict: bool = False
) -> None:
    """Download source tarball and upload to s3://koopa.acidgenomics.com/src/."""
    import tempfile

    from koopa.download import download

    url = _expand_src_url(src_url_template, version)
    filename = url.rsplit("/", 1)[-1]
    s3_key = f"s3://koopa.acidgenomics.com/src/{name}/{filename}"
    with tempfile.TemporaryDirectory() as tmp:
        local = os.path.join(tmp, filename)
        try:
            download(url, local, retry=False, connect_timeout=10, max_time=120)
        except Exception as exc:
            if strict:
                raise RuntimeError(f"Download failed for '{name}': {exc}") from exc
            print(f"  Mirror upload skipped for '{name}': download failed: {exc}", file=sys.stderr)
            return
        result = subprocess.run(
            ["aws", "s3", "cp", local, s3_key, "--profile", "acidgenomics"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode == 0:
            print(f"  Uploaded '{name}' source to {s3_key}", file=sys.stderr)
        else:
            msg = f"S3 upload failed for '{name}': {result.stderr.strip()}"
            if strict:
                raise RuntimeError(msg)
            print(f"  {msg}", file=sys.stderr)


def update_app_json(results: list[VersionCheckResult], *, s3_upload: bool = False) -> int:
    """Update app.json with latest versions and return count of changes."""
    outdated = [r for r in results if r.is_outdated or r.is_pinned_too_high]
    if not outdated:
        print("All versions are up to date.", file=sys.stderr)
        return 0
    json_path = Path(koopa_prefix()) / "etc" / "koopa" / "app.json"
    data = json.loads(json_path.read_text())
    today = time.strftime("%Y-%m-%d")
    count = 0
    for r in outdated:
        if r.name in data and r.latest_version:
            data[r.name]["version"] = r.latest_version
            data[r.name]["date"] = today
            count += 1
    export_app_json(data)
    print(f"Updated {count} app versions in app.json.", file=sys.stderr)
    bootstrap_count = update_bootstrap(data)
    if bootstrap_count > 0:
        print(
            f"Updated {bootstrap_count} versions in bootstrap.sh.",
            file=sys.stderr,
        )
    if s3_upload:
        if not _has_acidgenomics_aws():
            print("S3 upload skipped: 'acidgenomics' AWS profile not available.", file=sys.stderr)
        else:
            print("Uploading source tarballs to S3 mirror.", file=sys.stderr)
            for r in outdated:
                if r.name not in data or not r.latest_version:
                    continue
                src_url = data[r.name].get("src_url", "")
                if not src_url:
                    continue
                _mirror_src_to_s3(r.name, r.latest_version, src_url)
    return count


_BOOTSTRAP_APP_MAP: dict[str, str] = {
    "openssl": "openssl3",
    "python": "python3.12",
    "zlib": "zlib",
}


def update_bootstrap(app_data: dict[str, Any]) -> int:
    """Sync bootstrap.sh versions with app.json and bump bootstrap version."""
    bootstrap_path = Path(koopa_prefix()) / "bootstrap.sh"
    version_path = Path(koopa_prefix()) / "etc" / "koopa" / "bootstrap-version.txt"
    if not bootstrap_path.is_file():
        return 0
    text = bootstrap_path.read_text()
    count = 0
    for func_name, app_key in _BOOTSTRAP_APP_MAP.items():
        entry = app_data.get(app_key, {})
        if not isinstance(entry, dict):
            continue
        new_version = entry.get("version", "")
        if not new_version:
            continue
        pattern = re.compile(
            rf"(install_{re.escape(func_name)}\(\) \{{\n"
            rf"    __kvar_version=')([^']+)(')",
        )
        match = pattern.search(text)
        if match and match.group(2) != new_version:
            text = pattern.sub(rf"\g<1>{new_version}\g<3>", text)
            count += 1
            print(
                f"  bootstrap {func_name}: {match.group(2)} -> {new_version}",
                file=sys.stderr,
            )
    if count > 0:
        bootstrap_path.write_text(text)
        today = time.strftime("%Y.%m.%d.%H%M")
        version_path.write_text(today + "\n")
        print(f"  bootstrap version: {today}", file=sys.stderr)
    return count
