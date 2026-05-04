"""Primary CLI entry point for koopa.

Dispatches all ``koopa`` subcommands to the Python orchestrator.
Reads app metadata from ``app.json`` to resolve installer, platform, and
passthrough arguments -- eliminating the need for per-app Bash wrappers.
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


def _exec_restart_with_bootstrap() -> None:
    """Replace the current process with a fresh koopa invocation.

    Called after bootstrap is rebuilt so the rest of the update pipeline
    runs under the new Python interpreter rather than the stale one.
    """
    from koopa.prefix import bootstrap_prefix

    bp = bootstrap_prefix()
    new_python = os.path.join(bp, "bin", "python3")
    if not os.path.isfile(new_python):
        return  # nothing to restart with; let the caller continue best-effort
    koopa_prefix = _koopa_prefix()
    main_module = os.path.join(koopa_prefix, "lang", "python", "src", "koopa", "cli_main.py")
    # Ensure bootstrap lib dir is on LD_LIBRARY_PATH so the new Python can
    # find its openssl/zlib on Linux (macOS uses rpath baked at build time).
    bp_lib = os.path.join(bp, "lib")
    ld_path = os.environ.get("LD_LIBRARY_PATH", "")
    if bp_lib not in ld_path.split(":"):
        os.environ["LD_LIBRARY_PATH"] = f"{bp_lib}:{ld_path}".rstrip(":")
    os.execv(new_python, [new_python, main_module] + sys.argv[1:])


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
    """Build the argument parser for koopa CLI."""
    parser = argparse.ArgumentParser(
        prog="koopa",
        description="Shell bootloader for data science.",
    )
    subparsers = parser.add_subparsers(dest="command")

    # -- install --------------------------------------------------------------
    install_p = subparsers.add_parser("install")
    install_p.add_argument("apps", nargs="*")
    install_p.add_argument("--no-dependencies", action="store_true", default=False)
    install_p.add_argument("--private", action="store_true", default=False)
    install_p.add_argument("--reinstall", action="store_true", default=False)
    install_p.add_argument("--system", action="store_true", default=False)
    install_p.add_argument("--user", action="store_true", default=False)
    install_p.add_argument("-D", dest="passthrough", action="append", default=[])
    _add_common_flags(install_p)

    # -- reinstall ------------------------------------------------------------
    reinstall_p = subparsers.add_parser("reinstall")
    reinstall_p.add_argument("apps", nargs="+")
    reinstall_p.add_argument("--all-revdeps", action="store_true", default=False)
    reinstall_p.add_argument("--no-revdeps", action="store_true", default=False)
    reinstall_p.add_argument("--only-revdeps", action="store_true", default=False)
    _add_common_flags(reinstall_p)

    # -- uninstall ------------------------------------------------------------
    uninstall_p = subparsers.add_parser("uninstall")
    uninstall_p.add_argument("apps", nargs="*")
    uninstall_p.add_argument("--system", action="store_true", default=False)
    uninstall_p.add_argument("--user", action="store_true", default=False)
    uninstall_p.add_argument("--no-revdeps", action="store_true", default=False)
    _add_common_flags(uninstall_p)

    # -- update ---------------------------------------------------------------
    update_p = subparsers.add_parser("update")
    update_p.add_argument("apps", nargs="*")
    update_p.add_argument("--system", action="store_true", default=False)
    update_p.add_argument("--user", action="store_true", default=False)
    update_p.add_argument("--all-system", action="store_true", default=False)
    _add_common_flags(update_p)

    # -- configure ------------------------------------------------------------
    configure_p = subparsers.add_parser("configure")
    configure_p.add_argument("apps", nargs="*")
    configure_p.add_argument("--system", action="store_true", default=False)
    configure_p.add_argument("--user", action="store_true", default=False)
    _add_common_flags(configure_p)

    # -- app ------------------------------------------------------------------
    app_p = subparsers.add_parser("app")
    app_p.add_argument("remainder", nargs=argparse.REMAINDER)

    # -- system ---------------------------------------------------------------
    system_p = subparsers.add_parser("system")
    system_p.add_argument("remainder", nargs=argparse.REMAINDER)

    # -- develop --------------------------------------------------------------
    develop_p = subparsers.add_parser("develop")
    develop_p.add_argument("remainder", nargs=argparse.REMAINDER)

    # -- internal -------------------------------------------------------------
    internal_p = subparsers.add_parser("internal")
    internal_p.add_argument("remainder", nargs=argparse.REMAINDER)

    # -- simple commands ------------------------------------------------------
    subparsers.add_parser("version")
    subparsers.add_parser("header")
    subparsers.add_parser("install-all-apps")
    subparsers.add_parser("install-default-apps")
    subparsers.add_parser("list-all-apps")
    subparsers.add_parser("list-default-apps")

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
    from koopa.install import (
        _acquire_install_lock,
        _release_install_lock,
        install_app,
        install_koopa,
    )

    apps, mode = _resolve_apps_and_mode(args)
    if not apps:
        print("Error: no apps specified.", file=sys.stderr)
        sys.exit(1)
    if apps == ["koopa"]:
        install_koopa(verbose=args.verbose)
        return
    if "bootstrap" in apps:
        print(
            "Error: bootstrap is managed automatically by 'koopa update'.",
            file=sys.stderr,
        )
        sys.exit(1)
    acquired = _acquire_install_lock()
    try:
        extra = [f"--{p}" for p in args.passthrough] if args.passthrough else []
        for app in apps:
            config = _build_install_config(
                app,
                mode=mode,
                deps=not args.no_dependencies,
                private=getattr(args, "private", False),
                reinstall=args.reinstall,
                verbose=args.verbose,
                extra_passthrough=extra,
            )
            install_app(config)
    finally:
        if acquired:
            _release_install_lock()


def _handle_reinstall(args: argparse.Namespace) -> None:
    """Handle ``koopa reinstall`` subcommand."""
    from koopa.app import stale_revdeps
    from koopa.install import _acquire_install_lock, _release_install_lock, install_app

    apps = list(args.apps) if args.apps else []
    if not apps:
        print("Error: no apps specified.", file=sys.stderr)
        sys.exit(1)
    if "bootstrap" in apps:
        print(
            "Error: bootstrap is managed automatically by 'koopa update'.",
            file=sys.stderr,
        )
        sys.exit(1)
    acquired = _acquire_install_lock()
    try:
        if args.all_revdeps:
            _reinstall_with_revdeps(apps, mode="all", verbose=args.verbose)
            return
        if args.only_revdeps:
            _reinstall_with_revdeps(apps, mode="only", verbose=args.verbose)
            return
        for app in apps:
            config = _build_install_config(app, reinstall=True, verbose=args.verbose)
            install_app(config)
        if not args.no_revdeps:
            stale = stale_revdeps(apps)
            if stale:
                print(
                    f"Stale reverse dependencies: {', '.join(stale)}",
                    file=sys.stderr,
                )
                for dep in stale:
                    config = _build_install_config(dep, reinstall=True, verbose=args.verbose)
                    install_app(config)
    finally:
        if acquired:
            _release_install_lock()


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
    # Collect the union of revdeps across ALL input apps before reinstalling,
    # so shared reverse dependencies are only rebuilt once.
    for app in apps:
        revdeps = app_revdeps(app, mode="all")
        for rd in revdeps:
            if rd not in all_targets:
                all_targets.append(rd)
    if not all_targets:
        msg = "No reverse dependencies found."
        raise RuntimeError(msg)
    for app in all_targets:
        config = _build_install_config(app, reinstall=True, verbose=verbose)
        install_app(config)


def _handle_uninstall(args: argparse.Namespace) -> None:
    """Handle ``koopa uninstall`` subcommand."""
    from koopa.app import app_revdeps, installed_apps
    from koopa.install import _acquire_install_lock, _release_install_lock
    from koopa.uninstall import UninstallConfig, uninstall_app, uninstall_koopa

    apps, mode = _resolve_apps_and_mode(args)
    if not apps:
        apps = ["koopa"]
    if apps == ["koopa"]:
        uninstall_koopa()
        return
    # Block uninstall of apps that have installed reverse dependencies.
    if not args.no_revdeps:
        installed = set(installed_apps())
        blocked: dict[str, list[str]] = {}
        for app in apps:
            revdeps = [r for r in app_revdeps(app, mode="all") if r in installed and r not in apps]
            if revdeps:
                blocked[app] = revdeps
        if blocked:
            lines = ["Cannot uninstall — the following apps have installed reverse dependencies:"]
            for app, revdeps in sorted(blocked.items()):
                lines.append(f"  {app}: required by {', '.join(revdeps)}")
            lines.append(
                "Uninstall the dependent apps first, or use 'koopa uninstall --no-revdep-check' to override."
            )
            print("\n".join(lines), file=sys.stderr)
            sys.exit(1)
    acquired = _acquire_install_lock()
    try:
        for app in apps:
            config = UninstallConfig(name=app, mode=mode, verbose=args.verbose)
            uninstall_app(config)
    finally:
        if acquired:
            _release_install_lock()


def _configure_user_dotfiles() -> None:
    """Run dotfiles configurer if dotfiles and chezmoi are available."""
    import shutil

    from koopa.prefix import opt_prefix

    dotfiles_dir = os.path.join(opt_prefix(), "dotfiles")
    if not os.path.isdir(dotfiles_dir):
        return
    if shutil.which("chezmoi") is None:
        return
    from koopa.alert import warn
    from koopa.configure import ConfigureConfig, configure_app

    try:
        config = ConfigureConfig(name="dotfiles", mode="user")
        configure_app(config)
    except Exception as exc:
        warn(f"Dotfiles configuration failed: {exc}")


def _handle_update(args: argparse.Namespace) -> None:
    """Handle ``koopa update`` subcommand."""
    from koopa.install import (
        _acquire_install_lock,
        _release_install_lock,
        _update_venv,
        fetch_user_repos,
        install_missing_default_apps,
        remove_unsupported_apps,
        update_bootstrap,
        update_koopa,
        update_stale_apps,
        update_system_apps,
        update_user_apps,
    )

    if args.all_system or args.system:
        from koopa.system import is_admin

        if not is_admin():
            flag = "--all-system" if args.all_system else "--system"
            msg = f"{flag} requires admin/sudo access."
            raise PermissionError(msg)
    try:
        acquired = _acquire_install_lock()
    except RuntimeError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
    try:
        apps, mode = _resolve_apps_and_mode(args)
        if not apps:
            from koopa.alert import warn
            from koopa.app import prune_apps
            from koopa.check import prune_broken_symlinks

            update_koopa(verbose=args.verbose)
            bootstrap_rebuilt = update_bootstrap(verbose=args.verbose)
            if bootstrap_rebuilt:
                # Bootstrap Python version changed. The running interpreter's
                # stdlib paths are now stale. Exec-restart using the new
                # bootstrap Python so the rest of update runs cleanly.
                _release_install_lock()
                acquired = False
                _exec_restart_with_bootstrap()
                # Only reaches here if bootstrap binary not found — best-effort.
            _update_venv(_koopa_prefix())
            remove_unsupported_apps(verbose=args.verbose)
            update_stale_apps(verbose=args.verbose)
            install_missing_default_apps(verbose=args.verbose)
            update_user_apps(verbose=args.verbose)
            fetch_user_repos()
            _configure_user_dotfiles()
            prune_broken_symlinks()
            try:
                prune_apps()
            except (ValueError, OSError) as exc:
                warn(f"Prune failed: {exc}")
            if args.all_system:
                update_system_apps(verbose=args.verbose)
            return
        if apps == ["koopa"]:
            update_koopa(verbose=args.verbose)
            _update_venv(_koopa_prefix())
            return
        if apps:
            print(
                f"Error: 'koopa update' does not accept app names.\n"
                f"  To reinstall an app, use: koopa reinstall {' '.join(apps)}",
                file=sys.stderr,
            )
            sys.exit(1)
    finally:
        if acquired:
            _release_install_lock()


def _handle_configure(args: argparse.Namespace) -> None:
    """Handle ``koopa configure`` subcommand."""
    from koopa.configure import ConfigureConfig, configure_app

    apps = list(args.apps) if args.apps else []
    mode = _resolve_mode(args)
    if apps and apps[0] in ("system", "user"):
        if mode == "shared":
            mode = apps[0]
        apps = apps[1:]
    if not apps:
        print("Error: no apps specified.", file=sys.stderr)
        sys.exit(1)
    for app in apps:
        config = ConfigureConfig(
            name=app,
            mode=mode,
            verbose=args.verbose,
        )
        configure_app(config)


def _handle_app(args: argparse.Namespace) -> None:
    """Handle ``koopa app`` subcommand."""
    from koopa.cli_app import handle_app

    handle_app(args.remainder)


def _handle_internal(args: argparse.Namespace) -> None:
    """Handle ``koopa internal`` subcommand."""
    from koopa.cli_internal import handle_internal

    handle_internal(args.remainder)


def _handle_system(args: argparse.Namespace) -> None:
    """Handle ``koopa system`` subcommand."""
    from koopa.cli_system import handle_system

    handle_system(args.remainder)


def _handle_develop(args: argparse.Namespace) -> None:
    """Handle ``koopa develop`` subcommand."""
    from koopa.cli_develop import handle_develop

    handle_develop(args.remainder)


def _handle_version(_args: argparse.Namespace) -> None:
    """Handle ``koopa version`` subcommand."""
    from koopa.version import koopa_version

    print(koopa_version())


def _handle_header(_args: argparse.Namespace) -> None:
    """Handle ``koopa header`` subcommand."""
    from koopa.prefix import bash_prefix

    print(os.path.join(bash_prefix(), "include", "header.sh"))


def _handle_install_all_apps(_args: argparse.Namespace) -> None:
    """Handle ``koopa install-all-apps`` subcommand."""
    from koopa.install import install_all_apps

    install_all_apps()


def _handle_install_default_apps(_args: argparse.Namespace) -> None:
    """Handle ``koopa install-default-apps`` subcommand."""
    from koopa.install import install_default_apps

    install_default_apps()


def _handle_list_all_apps(_args: argparse.Namespace) -> None:
    """Handle ``koopa list-all-apps`` subcommand."""
    from koopa.cli import print_shared_apps

    print_shared_apps(mode="all")


def _handle_list_default_apps(_args: argparse.Namespace) -> None:
    """Handle ``koopa list-default-apps`` subcommand."""
    from koopa.cli import print_shared_apps

    print_shared_apps(mode="default")


# -- Entry point --------------------------------------------------------------


def main() -> None:
    """Primary CLI entry point."""
    argv = sys.argv[1:]
    if argv and argv[0] in ("--version", "-V"):
        from koopa.version import koopa_version

        print(koopa_version())
        return
    parser = _build_parser()
    args = parser.parse_args(argv)
    if args.command is None:
        parser.print_help()
        sys.exit(1)
    handlers = {
        "install": _handle_install,
        "reinstall": _handle_reinstall,
        "uninstall": _handle_uninstall,
        "update": _handle_update,
        "configure": _handle_configure,
        "app": _handle_app,
        "internal": _handle_internal,
        "system": _handle_system,
        "develop": _handle_develop,
        "version": _handle_version,
        "header": _handle_header,
        "install-all-apps": _handle_install_all_apps,
        "install-default-apps": _handle_install_default_apps,
        "list-all-apps": _handle_list_all_apps,
        "list-default-apps": _handle_list_default_apps,
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
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        if getattr(args, "verbose", False) or "--verbose" in sys.argv:
            import traceback

            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
