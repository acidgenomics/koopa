"""Upstream version checking for apps in app.json."""

from __future__ import annotations

import importlib
import inspect
import json
import os
import re
import sys
import threading
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass
from pathlib import Path

from koopa.installers import PYTHON_INSTALLERS
from koopa.io import import_app_json
from koopa.prefix import koopa_prefix
from koopa.version import sanitize_version


@dataclass
class VersionCheckResult:
    name: str
    current_version: str
    latest_version: str | None
    source: str
    error: str | None = None

    @property
    def is_outdated(self) -> bool:
        return (
            self.latest_version is not None
            and self.current_version != self.latest_version
        )


class _RateLimiter:
    def __init__(self, requests_per_second: float) -> None:
        self._interval = 1.0 / requests_per_second
        self._last: float = 0.0
        self._lock = threading.Lock()

    def wait(self) -> None:
        with self._lock:
            now = time.monotonic()
            wait = self._interval - (now - self._last)
            if wait > 0:
                time.sleep(wait)
            self._last = time.monotonic()


_github_token: str | None = os.environ.get("GITHUB_TOKEN") or os.environ.get(
    "GH_TOKEN"
)
_rate_github = _RateLimiter(1.2 if _github_token else 0.8)
_rate_default = _RateLimiter(5.0)

_INSTALLER_MODULE_RE = re.compile(r"koopa\.installers\.(_\w+)")
_GITHUB_REPO_RE = re.compile(
    r"github\.com/([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+?)(?:\.git|/|\"|\"|'|$)"
)


def _http_get_json(url: str, *, github: bool = False) -> dict | list:
    limiter = _rate_github if github else _rate_default
    limiter.wait()
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "koopa-version-checker")
    if github:
        req.add_header("Accept", "application/vnd.github+json")
        if _github_token:
            req.add_header("Authorization", f"Bearer {_github_token}")
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode())


def _http_get_text(url: str) -> str:
    _rate_default.wait()
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "koopa-version-checker")
    with urllib.request.urlopen(req, timeout=15) as resp:
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


def _check_conda(channel: str, package: str) -> str:
    data = _http_get_json(
        f"https://api.anaconda.org/package/{channel}/{package}"
    )
    return data["latest_version"]


def _check_gnu(
    package: str, *, parent: str = "", non_gnu_mirror: bool = False
) -> str:
    name = parent or package
    if non_gnu_mirror:
        base = f"https://download.savannah.nongnu.org/releases/{name}/"
    else:
        base = f"https://ftp.gnu.org/gnu/{name}/"
    html = _http_get_text(base)
    pattern = re.compile(
        rf"{re.escape(package)}[_-]([\d]+(?:\.[\d]+)*)\.tar\.(?:gz|xz|bz2|lz)"
    )
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
    data = _http_get_json(
        f"https://fastapi.metacpan.org/v1/release/{distribution}"
    )
    return sanitize_version(data["version"])


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
    check_fn: object
    args: tuple


def classify_app(name: str, info: dict) -> _AppCheckSpec | None:
    module_path = PYTHON_INSTALLERS.get(name, "")
    args = info.get("installer_args", {})
    urls = info.get("url", [])
    version = info.get("version", "")
    if len(version) == 40:
        return None
    for suffix, source in _GENERIC_INSTALLER_MAP.items():
        if module_path.endswith(suffix):
            return _classify_generic(source, name, info, args, urls)
    if module_path:
        gh_repo = _extract_github_repo_from_installer(module_path)
        if gh_repo:
            owner, repo = gh_repo.split("/", 1)
            return _AppCheckSpec("github", _check_github, (owner, repo))
    gh_repo = _extract_github_repo_from_urls(urls)
    if gh_repo:
        owner, repo = gh_repo.split("/", 1)
        return _AppCheckSpec("github", _check_github, (owner, repo))
    return None


def _classify_generic(
    source: str,
    name: str,
    info: dict,
    args: dict,
    urls: list[str],
) -> _AppCheckSpec | None:
    if source == "conda":
        pkg = _get_str(args, "name") or name
        channel = _infer_conda_channel(urls)
        return _AppCheckSpec("conda", _check_conda, (channel, pkg))
    if source == "pypi":
        pkg = _resolve_pypi_name(name, args, urls)
        return _AppCheckSpec("pypi", _check_pypi, (pkg,))
    if source == "gnu":
        pkg_name = _get_str(args, "package_name") or name
        parent = _get_str(args, "parent_name") or ""
        non_gnu = _get_str(args, "non_gnu_mirror") == "true"
        return _AppCheckSpec(
            "gnu",
            lambda p=pkg_name, pa=parent, ng=non_gnu: _check_gnu(
                p, parent=pa, non_gnu_mirror=ng
            ),
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


def _resolve_pypi_name(
    name: str, args: dict, urls: list[str]
) -> str:
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
    max_workers: int = 8,
) -> list[VersionCheckResult]:
    json_data = import_app_json()
    specs: list[tuple[str, str, _AppCheckSpec]] = []
    unsupported: list[VersionCheckResult] = []
    for app_name, info in sorted(json_data.items()):
        if name_filter and app_name not in name_filter:
            continue
        version = info.get("version", "")
        if not version:
            unsupported.append(
                VersionCheckResult(app_name, "", None, "none", "no version")
            )
            continue
        spec = classify_app(app_name, info)
        if spec is None:
            unsupported.append(
                VersionCheckResult(app_name, version, None, "unsupported", None)
            )
            continue
        if source_filter and spec.source != source_filter:
            continue
        specs.append((app_name, version, spec))
    total = len(specs)
    results: list[VersionCheckResult] = list(unsupported)
    if not specs:
        return results
    counter = {"n": 0}
    counter_lock = threading.Lock()

    def _run_check(
        app_name: str, current: str, spec: _AppCheckSpec
    ) -> VersionCheckResult:
        with counter_lock:
            counter["n"] += 1
            idx = counter["n"]
        try:
            latest = spec.check_fn(*spec.args)
            current_san = sanitize_version(current)
            latest_san = sanitize_version(latest)
            if current_san != latest_san:
                status = "outdated"
                print(
                    f"  [{idx}/{total}] {spec.source}: {app_name}... "
                    f"{current} -> {latest}",
                    file=sys.stderr,
                )
            else:
                status = "current"
                print(
                    f"  [{idx}/{total}] {spec.source}: {app_name}... ok",
                    file=sys.stderr,
                )
            return VersionCheckResult(
                app_name, current, latest, spec.source, None
            )
        except Exception as exc:
            print(
                f"  [{idx}/{total}] {spec.source}: {app_name}... "
                f"error: {exc}",
                file=sys.stderr,
            )
            return VersionCheckResult(
                app_name, current, None, spec.source, str(exc)
            )

    print(f"Checking {total} app versions...", file=sys.stderr)
    with ThreadPoolExecutor(max_workers=max_workers) as pool:
        futures = {
            pool.submit(_run_check, app_name, version, spec): app_name
            for app_name, version, spec in specs
        }
        for future in as_completed(futures):
            results.append(future.result())
    results.sort(key=lambda r: r.name)
    return results


# ── Reporting ─────────────────────────────────────────────────────────


def print_report(results: list[VersionCheckResult]) -> None:
    outdated = [r for r in results if r.is_outdated]
    current = [
        r
        for r in results
        if r.latest_version is not None and not r.is_outdated
    ]
    failed = [
        r
        for r in results
        if r.error is not None and r.source != "unsupported"
    ]
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
    if failed:
        print(f"Failed ({len(failed)}):")
        for r in sorted(failed, key=lambda x: x.name):
            print(f"  {r.name}: {r.error}")
        print()
    print(f"Up to date: {len(current)}")
    print(f"Outdated:   {len(outdated)}")
    print(f"Failed:     {len(failed)}")
    print(f"Unsupported: {len(unsupported)}")


def print_json_report(results: list[VersionCheckResult]) -> None:
    outdated = [asdict(r) for r in results if r.is_outdated]
    current = [
        asdict(r)
        for r in results
        if r.latest_version is not None and not r.is_outdated
    ]
    failed = [
        asdict(r)
        for r in results
        if r.error is not None and r.source != "unsupported"
    ]
    unsupported = [
        asdict(r)
        for r in results
        if r.source in ("unsupported", "none")
    ]
    print(
        json.dumps(
            {
                "outdated": outdated,
                "up_to_date": current,
                "failed": failed,
                "unsupported": unsupported,
            },
            indent=2,
        )
    )


# ── app.json updater ─────────────────────────────────────────────────


def update_app_json(results: list[VersionCheckResult]) -> int:
    outdated = [r for r in results if r.is_outdated]
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
    sorted_data = dict(sorted(data.items()))
    for key, value in sorted_data.items():
        if isinstance(value, dict):
            sorted_data[key] = dict(sorted(value.items()))
    json_path.write_text(
        json.dumps(sorted_data, indent=2, ensure_ascii=False) + "\n"
    )
    print(f"Updated {count} app versions in app.json.", file=sys.stderr)
    return count
