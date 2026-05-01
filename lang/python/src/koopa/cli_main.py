"""Primary CLI entry point for koopa install commands.

Dispatches ``koopa install``, ``koopa reinstall``, ``koopa uninstall``,
and ``koopa update`` subcommands to the Python install orchestrator.
Reads app metadata from ``app.json`` to resolve installer, platform, and
passthrough arguments — eliminating the need for per-app Bash wrappers.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import sys
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from koopa.install import InstallConfig


def _koopa_prefix() -> str:
    """Return koopa installation prefix."""
    return os.environ.get("KOOPA_PREFIX", "")


def _import_app_json() -> dict[str, Any]:
    """Import app.json data."""
    json_path = os.path.join(_koopa_prefix(), "etc", "koopa", "app.json")
    with open(json_path) as f:
        return json.load(f)


def _os_id() -> str:
    """Return platform-architecture ID (e.g. 'macos-arm64')."""
    machine = platform.machine()
    arch_map = {"x86_64": "amd64", "aarch64": "arm64", "arm64": "arm64"}
    arch = arch_map.get(machine, machine)
    if sys.platform == "darwin":
        return f"macos-{arch}"
    return f"linux-{arch}"


def _check_platform_support(name: str, app_meta: dict[str, Any]) -> None:
    """Abort if the app is not supported on the current platform."""
    supported = app_meta.get("supported", {})
    os_key = _os_id()
    if os_key in supported and not supported[os_key]:
        msg = f"'{name}' is not supported on {os_key}."
        raise RuntimeError(msg)


def _build_passthrough_args(app_meta: dict[str, Any]) -> list[str]:
    """Build passthrough -D args from app.json installer_args."""
    installer_args = app_meta.get("installer_args", {})
    if not installer_args:
        return []
    result: list[str] = []
    for key, value in installer_args.items():
        flag = key.replace("_", "-")
        if isinstance(value, list):
            for item in value:
                result.append(f"--{flag}={item}")
        else:
            result.append(f"--{flag}={value}")
    return result


def _build_install_config(
    name: str,
    *,
    mode: str = "shared",
    reinstall: bool = False,
    bootstrap: bool = False,
    verbose: bool = False,
    deps: bool = True,
    private: bool = False,
    extra_passthrough: list[str] | None = None,
) -> InstallConfig:
    """Build an InstallConfig from app.json metadata."""
    from koopa.install import InstallConfig, _can_install_binary, _can_push_binary

    app_data = _import_app_json()
    app_meta = app_data.get(name, {})
    _check_platform_support(name, app_meta)
    installer = app_meta.get("installer", "")
    installer_platform = app_meta.get("installer_platform", "common")
    is_private = app_meta.get("private", False) or private
    passthrough = _build_passthrough_args(app_meta)
    if extra_passthrough:
        passthrough.extend(extra_passthrough)
    note = app_meta.get("install_note", "")
    if note and not reinstall:
        print(f"Note: {note}", file=sys.stderr)
    return InstallConfig(
        name=name,
        mode=mode,
        installer=installer,
        platform=installer_platform,
        bootstrap=bootstrap,
        deps=deps,
        private=is_private,
        reinstall=reinstall,
        verbose=verbose,
        binary=_can_install_binary(),
        push=_can_push_binary(),
        passthrough_args=passthrough,
    )


# -- Argument parser ----------------------------------------------------------


def _add_common_flags(parser: argparse.ArgumentParser) -> None:
    """Add flags shared across subcommands."""
    parser.add_argument("--verbose", action="store_true", default=False)


def _build_parser() -> argparse.ArgumentParser:
    """Build the argument parser for koopa install commands."""
    parser = argparse.ArgumentParser(
        prog="koopa",
        description="Shell bootloader for data science.",
    )
    subparsers = parser.add_subparsers(dest="command")

    install_p = subparsers.add_parser("install")
    install_p.add_argument("apps", nargs="*")
    install_p.add_argument("--bootstrap", action="store_true", default=False)
    install_p.add_argument("--no-dependencies", action="store_true", default=False)
    install_p.add_argument("--private", action="store_true", default=False)
    install_p.add_argument("--reinstall", action="store_true", default=False)
    install_p.add_argument("--system", action="store_true", default=False)
    install_p.add_argument("--user", action="store_true", default=False)
    install_p.add_argument("-D", dest="passthrough", action="append", default=[])
    _add_common_flags(install_p)

    reinstall_p = subparsers.add_parser("reinstall")
    reinstall_p.add_argument("apps", nargs="+")
    reinstall_p.add_argument("--all-revdeps", action="store_true", default=False)
    reinstall_p.add_argument("--only-revdeps", action="store_true", default=False)
    _add_common_flags(reinstall_p)

    uninstall_p = subparsers.add_parser("uninstall")
    uninstall_p.add_argument("apps", nargs="*")
    uninstall_p.add_argument("--system", action="store_true", default=False)
    uninstall_p.add_argument("--user", action="store_true", default=False)
    _add_common_flags(uninstall_p)

    update_p = subparsers.add_parser("update")
    update_p.add_argument("apps", nargs="*")
    update_p.add_argument("--system", action="store_true", default=False)
    update_p.add_argument("--user", action="store_true", default=False)
    _add_common_flags(update_p)

    return parser


def _resolve_mode(args: argparse.Namespace) -> str:
    """Resolve installation mode from CLI flags."""
    if getattr(args, "system", False):
        return "system"
    if getattr(args, "user", False):
        return "user"
    return "shared"


def _resolve_apps_and_mode(
    args: argparse.Namespace,
) -> tuple[list[str], str]:
    """Handle the Bash convention of mode as first positional arg."""
    apps = list(args.apps) if args.apps else []
    mode = _resolve_mode(args)
    if apps and apps[0] in ("system", "user", "private"):
        if mode == "shared":
            mode = apps[0]
        apps = apps[1:]
    return apps, mode


# -- Subcommand handlers ------------------------------------------------------


def _handle_install(args: argparse.Namespace) -> None:
    """Handle ``koopa install`` subcommand."""
    from koopa.install import install_app, install_koopa

    apps, mode = _resolve_apps_and_mode(args)
    if not apps:
        print("Error: no apps specified.", file=sys.stderr)
        sys.exit(1)
    if apps == ["koopa"]:
        install_koopa(verbose=args.verbose)
        return
    extra = [f"--{p}" for p in args.passthrough] if args.passthrough else []
    for app in apps:
        config = _build_install_config(
            app,
            mode=mode,
            bootstrap=args.bootstrap,
            deps=not args.no_dependencies,
            private=getattr(args, "private", False),
            reinstall=args.reinstall,
            verbose=args.verbose,
            extra_passthrough=extra,
        )
        install_app(config)


def _handle_reinstall(args: argparse.Namespace) -> None:
    """Handle ``koopa reinstall`` subcommand."""
    from koopa.app import stale_revdeps
    from koopa.install import install_app

    apps = list(args.apps) if args.apps else []
    if not apps:
        print("Error: no apps specified.", file=sys.stderr)
        sys.exit(1)
    if args.all_revdeps:
        _reinstall_with_revdeps(apps, mode="all", verbose=args.verbose)
        return
    if args.only_revdeps:
        _reinstall_with_revdeps(apps, mode="only", verbose=args.verbose)
        return
    for app in apps:
        config = _build_install_config(app, reinstall=True, verbose=args.verbose)
        install_app(config)
    stale = stale_revdeps(apps)
    if stale:
        print(
            f"Stale reverse dependencies: {', '.join(stale)}",
            file=sys.stderr,
        )
        for dep in stale:
            config = _build_install_config(dep, reinstall=True, verbose=args.verbose)
            install_app(config)


def _reinstall_with_revdeps(
    apps: list[str],
    *,
    mode: str,
    verbose: bool = False,
) -> None:
    """Reinstall apps with reverse dependency handling."""
    from koopa.app import app_revdeps
    from koopa.install import install_app

    all_targets: list[str] = []
    if mode != "only":
        all_targets.extend(apps)
    for app in apps:
        revdeps = app_revdeps(app, mode="all")
        for rd in revdeps:
            if rd not in all_targets:
                all_targets.append(rd)
    for app in all_targets:
        config = _build_install_config(app, reinstall=True, verbose=verbose)
        install_app(config)


def _handle_uninstall(args: argparse.Namespace) -> None:
    """Handle ``koopa uninstall`` subcommand."""
    from koopa.uninstall import UninstallConfig, uninstall_app

    apps, mode = _resolve_apps_and_mode(args)
    if not apps:
        apps = ["koopa"]
    for app in apps:
        config = UninstallConfig(name=app, mode=mode, verbose=args.verbose)
        uninstall_app(config)


def _handle_update(args: argparse.Namespace) -> None:
    """Handle ``koopa update`` subcommand."""
    from koopa.install import install_app, install_koopa

    apps, mode = _resolve_apps_and_mode(args)
    if not apps:
        apps = ["koopa"]
    if apps == ["koopa"]:
        install_koopa(verbose=args.verbose)
        return
    for app in apps:
        config = _build_install_config(app, mode=mode, reinstall=True, verbose=args.verbose)
        install_app(config)


# -- Entry point --------------------------------------------------------------


def main() -> None:
    """Primary CLI entry point."""
    parser = _build_parser()
    args = parser.parse_args()
    if args.command is None:
        parser.print_help()
        sys.exit(1)
    handlers = {
        "install": _handle_install,
        "reinstall": _handle_reinstall,
        "uninstall": _handle_uninstall,
        "update": _handle_update,
    }
    handler = handlers.get(args.command)
    if handler is None:
        parser.print_help()
        sys.exit(1)
    try:
        handler(args)
    except KeyboardInterrupt:
        print("\nInterrupted.", file=sys.stderr)
        sys.exit(130)
    except Exception as exc:  # noqa: BLE001
        print(f"Error: {exc}", file=sys.stderr)
        if getattr(args, "verbose", False):
            import traceback

            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
