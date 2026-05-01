"""Dispatch table for ``koopa internal`` subcommands.

Replaces the standalone Python scripts in ``lang/python/scripts/``.
Each subcommand calls directly into the koopa package, eliminating the
Python-to-Bash-to-Python roundtrip.
"""

from __future__ import annotations

import sys


def handle_internal(remainder: list[str]) -> None:
    """Dispatch ``koopa internal ...`` commands."""
    if not remainder:
        print("Error: no internal command specified.", file=sys.stderr)
        sys.exit(1)
    subcmd = remainder[0]
    args = remainder[1:]
    handler = _HANDLERS.get(subcmd)
    if handler is None:
        print(f"Error: unknown internal command '{subcmd}'.", file=sys.stderr)
        sys.exit(1)
    handler(args)


def _handle_app_dependencies(args: list[str]) -> None:
    if len(args) != 1:
        print("Usage: koopa internal app-dependencies <name>", file=sys.stderr)
        sys.exit(1)
    from koopa.cli import print_app_deps

    try:
        print_app_deps(args[0])
    except NameError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


def _handle_app_json(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa internal app-json")
    parser.add_argument("--name", required=True)
    parser.add_argument("--key", required=True)
    parsed = parser.parse_args(args)
    from koopa.cli import print_app_json

    print_app_json(name=parsed.name, key=parsed.key)


def _handle_app_reverse_dependencies(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa internal app-reverse-dependencies",
    )
    parser.add_argument("--mode", choices=["all", "default"], default="default")
    parser.add_argument("name")
    parsed = parser.parse_args(args)
    from koopa.cli import print_app_revdeps

    print_app_revdeps(name=parsed.name, mode=parsed.mode)


def _handle_check_system(args: list[str]) -> None:
    from koopa.check import check_bootstrap_version, check_installed_apps

    ok = True
    if not check_bootstrap_version():
        ok = False
    if not check_installed_apps():
        ok = False
    if not ok:
        sys.exit(1)


def _handle_conda_bin_names(args: list[str]) -> None:
    if len(args) != 1:
        print(
            "Usage: koopa internal conda-bin-names <json_file>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.cli import print_conda_bin_names

    print_conda_bin_names(json_file=args[0])


def _handle_docker_build_all_tags(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa internal docker-build-all-tags",
    )
    parser.add_argument("--local", required=True)
    parser.add_argument("--remote", required=True)
    parsed = parser.parse_args(args)
    from koopa.shell.docker import build_all_tags

    build_all_tags(local=parsed.local, remote=parsed.remote)


def _handle_shared_apps(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa internal shared-apps")
    parser.add_argument("--mode", choices=["all", "default"], default="default")
    parsed = parser.parse_args(args)
    from koopa.cli import print_shared_apps

    print_shared_apps(mode=parsed.mode)


def _handle_stale_revdeps(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa internal stale-revdeps <names...>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.cli import print_stale_revdeps

    print_stale_revdeps(names=args)


def _handle_write_install_info(args: list[str]) -> None:
    if len(args) != 3:
        print(
            "Usage: koopa internal write-install-info"
            " <output_file> <name> <version>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.install_info import write_install_info

    write_install_info(
        output_file=args[0],
        name=args[1],
        version=args[2],
    )


_HANDLERS = {
    "app-dependencies": _handle_app_dependencies,
    "app-json": _handle_app_json,
    "app-reverse-dependencies": _handle_app_reverse_dependencies,
    "check-system": _handle_check_system,
    "conda-bin-names": _handle_conda_bin_names,
    "docker-build-all-tags": _handle_docker_build_all_tags,
    "shared-apps": _handle_shared_apps,
    "stale-revdeps": _handle_stale_revdeps,
    "write-install-info": _handle_write_install_info,
}
