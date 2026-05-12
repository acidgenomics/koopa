"""Shared helpers for build-from-source installers."""

import os
from glob import glob
from pathlib import Path
from typing import TYPE_CHECKING
from urllib.parse import urlparse

from koopa.archive import extract
from koopa.download import download, download_with_mirror
from koopa.io import import_json

if TYPE_CHECKING:
    from koopa.build import BuildEnv


def _resolve_src_url(name: str, version: str) -> str:
    """Look up and expand src_url from app.json for the given app."""
    from koopa.version_check import _expand_src_url

    koopa_prefix = str(Path(__file__).resolve().parents[5])
    json_path = os.path.join(koopa_prefix, "etc", "koopa", "app.json")
    data = import_json(json_path)
    entry = data.get(name, {})
    template = entry.get("src_url", "")
    if not template:
        msg = f"No 'src_url' in app.json for '{name}'."
        raise ValueError(msg)
    return _expand_src_url(template, version)


def _resolve_extra_src_urls(name: str, version: str) -> list[str]:
    """Look up and expand extra_src_urls from app.json for the given app."""
    from koopa.version_check import _expand_src_url

    koopa_prefix = str(Path(__file__).resolve().parents[5])
    json_path = os.path.join(koopa_prefix, "etc", "koopa", "app.json")
    data = import_json(json_path)
    entry = data.get(name, {})
    templates = entry.get("extra_src_urls", [])
    return [_expand_src_url(t, version) for t in templates]


def download_extract_cd(url: str | None = None) -> None:
    """Download a tarball, extract into ``src/``, and chdir into it."""
    from koopa.installers._context import get_app_name, get_app_version

    name = get_app_name()
    if url is None:
        version = get_app_version()
        if not name or not version:
            msg = "App name and version context required when url is not provided."
            raise ValueError(msg)
        url = _resolve_src_url(name, version)
    if name:
        filename = os.path.basename(urlparse(url).path)
        tarball = download_with_mirror(url, name, filename)
    else:
        tarball = download(url)
    extract_cd(tarball)


def extract_cd(tarball: str) -> None:
    """Extract a tarball into ``src/`` and chdir into it."""
    extract(tarball, "src")
    os.chdir("src")


def activate_app_deps() -> "BuildEnv":
    """Activate build_dependencies and dependencies from app.json for the current app."""
    from koopa.app import _resolve_dep_dict
    from koopa.build import BuildEnv, activate_app
    from koopa.installers._context import get_app_name
    from koopa.io import import_json
    from koopa.os import os_id

    name = get_app_name()
    koopa_prefix = str(Path(__file__).resolve().parents[5])
    json_path = os.path.join(koopa_prefix, "etc", "koopa", "app.json")
    data = import_json(json_path)
    entry = data.get(name, {})
    sys_dict = {"os_id": os_id()}
    build_deps = entry.get("build_dependencies", [])
    deps = entry.get("dependencies", [])
    if isinstance(build_deps, dict):
        build_deps = _resolve_dep_dict(build_deps, sys_dict)
    elif isinstance(build_deps, str):
        build_deps = [build_deps]
    if isinstance(deps, dict):
        deps = _resolve_dep_dict(deps, sys_dict)
    elif isinstance(deps, str):
        deps = [deps]
    env = BuildEnv()
    if build_deps:
        env = activate_app(*build_deps, build_only=True)
    if deps:
        env = activate_app(*deps, env=env)
    return env


def remove_static_libs(prefix: str) -> None:
    """Remove static ``.a`` libraries from prefix lib directory."""
    for f in glob(os.path.join(prefix, "lib", "*.a")):
        os.unlink(f)
