"""Generic GNU app installer."""

from __future__ import annotations

import json
import os
from pathlib import Path

from koopa.build import activate_app
from koopa.install import install_gnu_app
from koopa.installers._args import get_str, parse_passthrough


def _get_app_deps(name: str) -> tuple[list[str], list[str]]:
    """Get build_dependencies and dependencies for an app from app.json."""
    from koopa.app import _resolve_dep_dict
    from koopa.os import os_id

    koopa_prefix = str(Path(__file__).resolve().parents[5])
    json_path = os.path.join(koopa_prefix, "etc", "koopa", "app.json")
    with open(json_path) as f:
        data = json.load(f)
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
    return build_deps, deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a GNU app from source."""
    build_deps, deps = _get_app_deps(name)
    env = None
    if build_deps:
        env = activate_app(*build_deps, build_only=True)
    if deps:
        env = activate_app(*deps, env=env)
    if env is not None:
        env.apply()
    kwargs = parse_passthrough(passthrough_args)
    known_keys = {"compress_ext", "package_name", "parent_name", "non_gnu_mirror"}
    conf_args: list[str] = []
    for key, value in kwargs.items():
        if key in known_keys:
            continue
        flag = f"--{key.replace('_', '-')}"
        if isinstance(value, list):
            for v in value:
                conf_args.append(f"{flag}={v}" if v else flag)
        elif value:
            conf_args.append(f"{flag}={value}")
        else:
            conf_args.append(flag)
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        compress_ext=get_str(kwargs, "compress_ext", "gz"),
        package_name=get_str(kwargs, "package_name"),
        parent_name=get_str(kwargs, "parent_name"),
        non_gnu_mirror=get_str(kwargs, "non_gnu_mirror") == "true",
        conf_args=conf_args or None,
    )
