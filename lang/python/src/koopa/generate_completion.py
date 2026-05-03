"""Generate bash/zsh TAB completion file for koopa.

Auto-generates ``etc/completion/koopa.sh`` from the Python dispatch tables,
``app.json``, and AST-extracted argparse flags.

Usage::

    koopa develop generate-completion          # print to stdout
    koopa develop generate-completion --write  # overwrite koopa.sh
"""

from __future__ import annotations

import ast
import os
from datetime import date
from typing import Any

# ---------------------------------------------------------------------------
# Static data: commands that cannot be introspected from Python dispatch
# tables.  Each entry is (name, platform) where platform is None (all),
# "linux", "macos", "debian", "fedora", or "debian_or_fedora".
# ---------------------------------------------------------------------------

_SYSTEM_COMMANDS: list[tuple[str, str | None]] = [
    ("check", None),
    ("disable-passwordless-sudo", None),
    ("enable-passwordless-sudo", None),
    ("hostname", None),
    ("info", None),
    ("list", None),
    ("os-string", None),
    ("prefix", None),
    ("prune-apps", None),
    ("switch-to-develop", None),
    ("test", None),
    ("update-tex-packages", None),
    ("version", None),
    ("which", None),
    ("zsh-compaudit-set-permissions", None),
    ("delete-cache", "linux"),
    ("fix-sudo-setrlimit-error", "linux"),
    ("clean-launch-services", "macos"),
    ("create-dmg", "macos"),
    ("disable-touch-id-sudo", "macos"),
    ("enable-touch-id-sudo", "macos"),
    ("flush-dns", "macos"),
    ("force-eject", "macos"),
    ("ifactive", "macos"),
    ("reload-autofs", "macos"),
    ("spotlight", "macos"),
]

_SYSTEM_LIST: list[tuple[str, str | None]] = [
    ("app-versions", None),
    ("path-priority", None),
    ("launch-agents", "macos"),
]

_INSTALL_SYSTEM_INSTALL: list[tuple[str, str | None]] = [
    ("homebrew-bundle", None),
    ("tex-packages", None),
    ("rosetta", "macos"),
]

_INSTALL_SYSTEM_SYSTEM: list[tuple[str, str | None]] = [
    ("homebrew", None),
    ("pihole", "linux"),
    ("pivpn", "linux"),
    ("wine", "linux"),
    ("rstudio-server", "debian_or_fedora"),
    ("shiny-server", "debian_or_fedora"),
    ("aws-mountpoint-s3", "debian"),
    ("docker", "debian"),
    ("r", "debian"),
    ("oracle-instant-client", "fedora"),
    ("python", "macos"),
    ("r", "macos"),
    ("r-gfortran", "macos"),
    ("r-xcode-openmp", "macos"),
    ("xcode-clt", "macos"),
]

_INSTALL_PRIVATE: list[tuple[str, str | None]] = [
    ("ont-guppy", None),
    ("bcl2fastq", "linux"),
    ("cellranger", "linux"),
]

_INSTALL_USER: list[tuple[str, str | None]] = [
    ("bootstrap", None),
    ("doom-emacs", None),
    ("prelude-emacs", None),
    ("spacemacs", None),
    ("spacevim", None),
]

_CONFIGURE_SYSTEM: list[tuple[str, str | None]] = [
    ("r", None),
    ("lmod", "linux"),
    ("rstudio-server", "linux"),
    ("sshd", "linux"),
    ("base", "debian"),
    ("preferences", "macos"),
]

_CONFIGURE_USER: list[tuple[str, str | None]] = [
    ("chemacs", None),
    ("dotfiles", None),
    ("preferences", "macos"),
]

_UPDATE_SYSTEM: list[tuple[str, str | None]] = [
    ("homebrew", None),
    ("tex-packages", None),
]

# Flags for top-level subcommands defined in _build_parser() — these cannot
# be discovered via AST (they live outside handler functions) so they are
# maintained as a static mapping.
_MAIN_COMMAND_FLAGS: dict[str, list[str]] = {
    "configure": ["--help", "--system", "--user", "--verbose"],
    "install": [
        "--help",
        "--no-dependencies",
        "--private",
        "--reinstall",
        "--system",
        "--user",
        "--verbose",
    ],
    "reinstall": ["--help", "--all-revdeps", "--no-revdeps", "--only-revdeps", "--verbose"],
    "uninstall": ["--help", "--no-revdeps", "--system", "--user", "--verbose"],
    "update": ["--help", "--all-system", "--system", "--user", "--verbose"],
    "develop/remove-app": ["--help", "--revdeps"],
}


# ---------------------------------------------------------------------------
# Data loaders
# ---------------------------------------------------------------------------


def _load_app_tree() -> dict[str, Any]:
    from koopa.cli_app import _APP_TREE

    return _APP_TREE


def _load_develop_commands() -> list[str]:
    from koopa.cli_develop import _DEVELOP_HANDLERS

    return sorted(_DEVELOP_HANDLERS.keys())


def _load_app_names() -> tuple[list[str], list[str], list[str]]:
    """Return (common, linux_only, macos_only) app name lists."""
    from koopa.io import import_app_json

    data = import_app_json()
    common: list[str] = []
    linux: list[str] = []
    macos: list[str] = []
    for name, meta in sorted(data.items()):
        plat = meta.get("installer_platform", "common")
        if plat == "linux":
            linux.append(name)
        elif plat == "macos":
            macos.append(name)
        else:
            common.append(name)
    return common, linux, macos


# ---------------------------------------------------------------------------
# AST flag extraction
# ---------------------------------------------------------------------------


def _extract_handler_flags(filepath: str) -> dict[str, list[str]]:
    """AST-parse a Python file and extract ``--flags`` from handlers.

    Returns a dict mapping function names (e.g. ``_handle_aws_s3_sync``)
    to their list of ``--flag`` strings.
    """
    with open(filepath) as f:
        tree = ast.parse(f.read())
    result: dict[str, list[str]] = {}
    for node in ast.walk(tree):
        if not isinstance(node, ast.FunctionDef):
            continue
        if not node.name.startswith("_handle_"):
            continue
        flags: list[str] = []
        for child in ast.walk(node):
            if not isinstance(child, ast.Call):
                continue
            func = child.func
            if not (isinstance(func, ast.Attribute) and func.attr == "add_argument"):
                continue
            if not child.args:
                continue
            arg0 = child.args[0]
            if (
                isinstance(arg0, ast.Constant)
                and isinstance(arg0.value, str)
                and arg0.value.startswith("--")
            ):
                flags.append(arg0.value)
        if flags:
            result[node.name] = flags
    return result


def _extract_handler_key_to_func(filepath: str) -> dict[str, str]:
    """AST-parse handler dicts to map handler keys to function names.

    Handles direct references, lambdas wrapping calls, and call expressions
    (factory functions).
    """
    with open(filepath) as f:
        tree = ast.parse(f.read())
    result: dict[str, str] = {}
    _target_names = ("_PYTHON_HANDLERS", "_DEVELOP_HANDLERS")
    for node in ast.walk(tree):
        target_name = ""
        value: ast.expr | None = None
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
            target_name = node.target.id
            value = node.value
        elif isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name):
                    target_name = t.id
            value = node.value
        if target_name not in _target_names or not isinstance(value, ast.Dict):
            continue
        for key_node, val_node in zip(value.keys, value.values, strict=True):
            if not isinstance(key_node, ast.Constant) or not isinstance(key_node.value, str):
                continue
            handler_key: str = key_node.value
            if isinstance(val_node, ast.Name):
                result[handler_key] = val_node.id
            elif isinstance(val_node, ast.Lambda):
                body = val_node.body
                if isinstance(body, ast.Call) and isinstance(body.func, ast.Name):
                    result[handler_key] = body.func.id
            elif isinstance(val_node, ast.Call) and isinstance(val_node.func, ast.Name):
                result[handler_key] = val_node.func.id
    return result


# ---------------------------------------------------------------------------
# Flag map builder
# ---------------------------------------------------------------------------


def _build_flag_map(
    app_tree: dict[str, Any],
    key_to_func: dict[str, str],
    handler_flags: dict[str, list[str]],
    *,
    prefix: tuple[str, ...] = (),
) -> dict[str, list[str]]:
    """Walk ``_APP_TREE`` and build a ``path -> flags`` mapping."""
    result: dict[str, list[str]] = {}
    for key, value in sorted(app_tree.items()):
        path = (*prefix, key)
        if isinstance(value, str):
            func_name = key_to_func.get(value, "")
            flags = handler_flags.get(func_name, [])
            if flags:
                path_str = "app/" + "/".join(path)
                result[path_str] = ["--help", *flags]
        elif isinstance(value, dict):
            result.update(_build_flag_map(value, key_to_func, handler_flags, prefix=path))
    return result


# ---------------------------------------------------------------------------
# Shell emission helpers
# ---------------------------------------------------------------------------

_I = "    "


def _emit_platform_block(
    entries: list[tuple[str, str | None]],
    indent: str,
) -> list[str]:
    """Emit args+= lines with platform conditionals."""
    lines: list[str] = []
    common = sorted(e[0] for e in entries if e[1] is None)
    linux = sorted(e[0] for e in entries if e[1] == "linux")
    macos = sorted(e[0] for e in entries if e[1] == "macos")
    debian = sorted(e[0] for e in entries if e[1] == "debian")
    fedora = sorted(e[0] for e in entries if e[1] == "fedora")
    debian_or_fedora = sorted(e[0] for e in entries if e[1] == "debian_or_fedora")
    if common:
        lines.extend(_emit_args_array(common, indent))
    if linux:
        lines.append(f"{indent}if _koopa_is_linux")
        lines.append(f"{indent}then")
        lines.extend(_emit_args_array(linux, f"{indent}{_I}"))
        lines.append(f"{indent}fi")
    if macos:
        lines.append(f"{indent}if _koopa_is_macos")
        lines.append(f"{indent}then")
        lines.extend(_emit_args_array(macos, f"{indent}{_I}"))
        lines.append(f"{indent}fi")
    if debian_or_fedora:
        lines.append(f"{indent}if grep -q 'debian' /etc/os-release 2>/dev/null || \\")
        lines.append(f"{indent}   grep -q 'fedora' /etc/os-release 2>/dev/null")
        lines.append(f"{indent}then")
        lines.extend(_emit_args_array(debian_or_fedora, f"{indent}{_I}"))
        lines.append(f"{indent}fi")
    if debian:
        lines.append(f"{indent}if grep -q 'debian' /etc/os-release 2>/dev/null")
        lines.append(f"{indent}then")
        lines.extend(_emit_args_array(debian, f"{indent}{_I}"))
        lines.append(f"{indent}fi")
    if fedora:
        lines.append(f"{indent}if grep -q 'fedora' /etc/os-release 2>/dev/null")
        lines.append(f"{indent}then")
        lines.extend(_emit_args_array(fedora, f"{indent}{_I}"))
        lines.append(f"{indent}fi")
    return lines


def _emit_args_array(names: list[str], indent: str) -> list[str]:
    """Emit a shell ``args+=( ... )`` block."""
    if not names:
        return []
    if len(names) == 1:
        return [f"{indent}args+=('{names[0]}')"]
    lines = [f"{indent}args+=("]
    for name in sorted(names):
        lines.append(f"{indent}{_I}'{name}'")
    lines.append(f"{indent})")
    return lines


def _emit_case_entry(
    pattern: str,
    body_lines: list[str],
    indent: str,
) -> list[str]:
    """Emit a single case pattern with body."""
    lines = [f"{indent}{pattern}"]
    lines.extend(body_lines)
    lines.append(f"{indent}{_I};;")
    return lines


# ---------------------------------------------------------------------------
# Tree walking for app subcommands
# ---------------------------------------------------------------------------


def _collect_app_depth_2(tree: dict[str, Any]) -> list[str]:
    """Return sorted top-level keys of ``_APP_TREE`` (COMP_CWORD=3)."""
    return sorted(tree.keys())


def _collect_app_depth_3(
    tree: dict[str, Any],
) -> dict[str, list[str]]:
    """Return mapping of parent -> sorted children at depth 3 (COMP_CWORD=4).

    Only includes parents whose value is a dict (branch nodes).
    """
    result: dict[str, list[str]] = {}
    for key, value in sorted(tree.items()):
        if isinstance(value, dict):
            result[key] = sorted(value.keys())
    return result


def _collect_app_depth_4(
    tree: dict[str, Any],
) -> dict[tuple[str, str], list[str]]:
    """Return mapping of (grandparent, parent) -> sorted children at depth 4.

    Only for nodes three levels deep (COMP_CWORD=5).
    """
    result: dict[tuple[str, str], list[str]] = {}
    for gp_key, gp_val in sorted(tree.items()):
        if not isinstance(gp_val, dict):
            continue
        for p_key, p_val in sorted(gp_val.items()):
            if isinstance(p_val, dict):
                result[(gp_key, str(p_key))] = sorted(str(k) for k in p_val)
    return result


# ---------------------------------------------------------------------------
# Main generator
# ---------------------------------------------------------------------------


def generate_completion() -> None:  # noqa: PLR0915
    """Generate the ``koopa.sh`` bash completion file."""
    from koopa.prefix import koopa_prefix

    src_dir = os.path.join(koopa_prefix(), "lang", "python", "src", "koopa")
    cli_app_path = os.path.join(src_dir, "cli_app.py")
    cli_develop_path = os.path.join(src_dir, "cli_develop.py")

    app_tree = _load_app_tree()
    develop_cmds = _load_develop_commands()
    common_apps, linux_apps, macos_apps = _load_app_names()

    app_handler_flags = _extract_handler_flags(cli_app_path)
    dev_handler_flags = _extract_handler_flags(cli_develop_path)
    app_key_to_func = _extract_handler_key_to_func(cli_app_path)
    dev_key_to_func = _extract_handler_key_to_func(cli_develop_path)

    flag_map = _build_flag_map(app_tree, app_key_to_func, app_handler_flags)
    for dev_key, dev_func in dev_key_to_func.items():
        flags = dev_handler_flags.get(dev_func, [])
        if flags:
            flag_map[f"develop/{dev_key}"] = ["--help", *flags]
    flag_map.update(_MAIN_COMMAND_FLAGS)

    today = date.today().strftime("%Y-%m-%d")
    i2 = _I * 2
    i3 = _I * 3
    i4 = _I * 4
    i5 = _I * 5
    i6 = _I * 6

    lines: list[str] = []

    # -- Header ---------------------------------------------------------------
    lines.append("#!/usr/bin/env bash")
    lines.append("# shellcheck disable=SC2207")
    lines.append("")
    lines.append("_koopa_complete() {")
    lines.append(f'{_I}# """')
    lines.append(f"{_I}# Bash/Zsh TAB completion for primary 'koopa' program.")
    lines.append(f"{_I}# @note Updated {today}.")
    lines.append(f"{_I}# @note Auto-generated by 'koopa develop generate-completion'.")
    lines.append(f'{_I}# """')
    lines.append(f"{_I}local args")
    lines.append(f"{_I}COMPREPLY=()")

    # -- Flags associative array ----------------------------------------------
    lines.append(f"{_I}local -A _flags")
    lines.append(f"{_I}_flags=(")
    for path_key in sorted(flag_map):
        flags_str = " ".join(flag_map[path_key])
        lines.append(f"{i2}['{path_key}']='{flags_str}'")
    lines.append(f"{_I})")

    # -- COMP_CWORD case ------------------------------------------------------
    lines.append(f'{_I}case "${{COMP_CWORD:-}}" in')

    # ---- COMP_CWORD=1: top-level -------------------------------------------
    lines.append(f"{i2}'1')")
    lines.extend(
        _emit_args_array(
            [
                "--help",
                "--version",
                "app",
                "configure",
                "develop",
                "header",
                "install",
                "install-all-apps",
                "install-default-apps",
                "internal",
                "list-all-apps",
                "list-default-apps",
                "reinstall",
                "system",
                "uninstall",
                "update",
                "version",
            ],
            i3,
        )
    )
    lines.append(f"{i3};;")

    # ---- COMP_CWORD=2 ------------------------------------------------------
    lines.append(f"{i2}'2')")
    lines.append(f'{i3}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')

    # app
    app_top = _collect_app_depth_2(app_tree)
    lines.extend(
        _emit_case_entry(
            "'app')",
            _emit_args_array(app_top, i5),
            i4,
        )
    )

    # configure
    lines.extend(
        _emit_case_entry(
            "'configure')",
            [f"{i5}args+=('system' 'user')"],
            i4,
        )
    )

    # develop
    lines.extend(
        _emit_case_entry(
            "'develop')",
            _emit_args_array(develop_cmds, i5),
            i4,
        )
    )

    # header
    lines.extend(
        _emit_case_entry(
            "'header')",
            [f"{i5}args+=('bash' 'posix' 'zsh')"],
            i4,
        )
    )

    # install | reinstall | uninstall
    install_body: list[str] = []
    install_body.extend(_emit_args_array(common_apps, i5))
    if linux_apps:
        install_body.append(f"{i5}if _koopa_is_linux")
        install_body.append(f"{i5}then")
        install_body.extend(_emit_args_array(linux_apps, i6))
        install_body.append(f"{i5}fi")
    if macos_apps:
        install_body.append(f"{i5}if _koopa_is_macos")
        install_body.append(f"{i5}then")
        install_body.extend(_emit_args_array(macos_apps, i6))
        install_body.append(f"{i5}fi")
    install_body.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
    install_body.append(f"{i6}'install' | \\")
    install_body.append(f"{i6}'uninstall')")
    install_body.append(f"{i6}{_I}args+=('private' 'system' 'user')")
    install_body.append(f"{i6}{_I};;")
    install_body.append(f"{i6}'reinstall')")
    install_body.append(f"{i6}{_I}args+=('--all-revdeps' '--no-revdeps' '--only-revdeps')")
    install_body.append(f"{i6}{_I};;")
    install_body.append(f"{i5}esac")
    lines.extend(
        _emit_case_entry(
            "'install' | \\",
            [f"{i4}'reinstall' | \\", f"{i4}'uninstall')", *install_body],
            i4,
        )
    )

    # system
    lines.extend(
        _emit_case_entry(
            "'system')",
            _emit_platform_block(_SYSTEM_COMMANDS, i5),
            i4,
        )
    )

    # update
    lines.extend(
        _emit_case_entry(
            "'update')",
            [f"{i5}args+=('koopa' 'system')"],
            i4,
        )
    )

    # wildcard
    lines.append(f"{i4}*)")
    lines.append(f"{i5};;")
    lines.append(f"{i3}esac")
    lines.append(f"{i3};;")

    # ---- COMP_CWORD=3 ------------------------------------------------------
    lines.append(f"{i2}'3')")
    lines.append(f'{i3}case "${{COMP_WORDS[COMP_CWORD-2]}}" in')

    # configure
    lines.append(f"{i4}'configure')")
    lines.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
    lines.extend(
        _emit_case_entry(
            "'system')",
            _emit_platform_block(_CONFIGURE_SYSTEM, i6 + _I),
            i6,
        )
    )
    lines.extend(
        _emit_case_entry(
            "'user')",
            _emit_platform_block(_CONFIGURE_USER, i6 + _I),
            i6,
        )
    )
    lines.append(f"{i6}esac")
    lines.append(f"{i4};;")

    # install | uninstall
    lines.append(f"{i4}'install' | \\")
    lines.append(f"{i4}'uninstall')")
    lines.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-2]}}" in')
    lines.append(f"{i6}'install')")
    lines.append(f'{i6}{_I}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
    lines.extend(
        _emit_case_entry(
            "'system')",
            _emit_platform_block(_INSTALL_SYSTEM_INSTALL, i6 + _I * 3 + _I),
            i6 + _I * 3,
        )
    )
    lines.append(f"{i6}{_I}{_I}esac")
    lines.append(f"{i6}{_I};;")
    lines.append(f"{i5}esac")

    lines.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
    lines.extend(
        _emit_case_entry(
            "'private')",
            _emit_platform_block(_INSTALL_PRIVATE, i6 + _I),
            i6,
        )
    )
    lines.extend(
        _emit_case_entry(
            "'system')",
            _emit_platform_block(_INSTALL_SYSTEM_SYSTEM, i6 + _I),
            i6,
        )
    )
    lines.extend(
        _emit_case_entry(
            "'user')",
            _emit_platform_block(_INSTALL_USER, i6 + _I),
            i6,
        )
    )
    lines.append(f"{i6}esac")
    lines.append(f"{i6};;")

    # update
    lines.append(f"{i4}'update')")
    lines.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
    lines.extend(
        _emit_case_entry(
            "'system')",
            _emit_platform_block(_UPDATE_SYSTEM, i6 + _I),
            i6,
        )
    )
    lines.append(f"{i6}esac")
    lines.append(f"{i6};;")

    # system
    lines.append(f"{i4}'system')")
    lines.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
    lines.extend(
        _emit_case_entry(
            "'list')",
            _emit_platform_block(_SYSTEM_LIST, i6 + _I),
            i6,
        )
    )
    lines.append(f"{i6}esac")
    lines.append(f"{i6};;")

    # app at depth 3
    lines.append(f"{i4}'app')")
    lines.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
    app_d3 = _collect_app_depth_3(app_tree)
    for parent, children in sorted(app_d3.items()):
        # Check if multiple parents share the same children set.
        lines.extend(
            _emit_case_entry(
                f"'{parent}')",
                _emit_args_array(children, i6 + _I),
                i6,
            )
        )
    # Also emit leaf-only parents that have string values (no sub-levels
    # but are themselves a category like 'rnaeditingindexer').
    for key, value in sorted(app_tree.items()):
        if isinstance(value, str) and key not in app_d3:
            pass
    lines.append(f"{i5}esac")
    lines.append(f"{i5};;")

    lines.append(f"{i3}esac")
    lines.append(f"{i3};;")

    # ---- COMP_CWORD=4 ------------------------------------------------------
    lines.append(f"{i2}'4')")
    lines.append(f'{i3}case "${{COMP_WORDS[COMP_CWORD-3]}}" in')
    lines.append(f"{i4}'app')")
    lines.append(f'{i5}case "${{COMP_WORDS[COMP_CWORD-2]}}" in')
    app_d4 = _collect_app_depth_4(app_tree)
    # Group by grandparent where children are the same.
    gp_groups: dict[str, dict[str, list[str]]] = {}
    for (gp, parent), children in sorted(app_d4.items()):
        if gp not in gp_groups:
            gp_groups[gp] = {}
        gp_groups[gp][parent] = children
    for gp in sorted(gp_groups):
        lines.append(f"{i6}'{gp}')")
        lines.append(f'{i6}{_I}case "${{COMP_WORDS[COMP_CWORD-1]}}" in')
        for parent, children in sorted(gp_groups[gp].items()):
            lines.extend(
                _emit_case_entry(
                    f"'{parent}')",
                    _emit_args_array(children, i6 + _I * 3),
                    i6 + _I * 2,
                )
            )
        lines.append(f"{i6}{_I}esac")
        lines.append(f"{i6}{_I};;")
    lines.append(f"{i5}esac")
    lines.append(f"{i5};;")
    lines.append(f"{i3}esac")
    lines.append(f"{i3};;")

    # Close COMP_CWORD case.
    lines.append(f"{_I}esac")

    # -- Flag completion block ------------------------------------------------
    lines.append(f"{_I}# Flag completion: when the current word starts with '--', look up")
    lines.append(f"{_I}# available flags for the resolved command path.")
    lines.append(f'{_I}if [[ "${{COMP_WORDS[COMP_CWORD]}}" == --* ]]')
    lines.append(f"{_I}then")
    lines.append(f"{i2}local _path=''")
    lines.append(f"{i2}local _i")
    lines.append(f"{i2}for (( _i=1; _i < COMP_CWORD; _i++ ))")
    lines.append(f"{i2}do")
    lines.append(f'{i3}case "${{COMP_WORDS[_i]}}" in')
    lines.append(f"{i4}--*)")
    lines.append(f"{i5};;")
    lines.append(f"{i4}*)")
    lines.append(f'{i5}if [[ -z "$_path" ]]')
    lines.append(f"{i5}then")
    lines.append(f'{i6}_path="${{COMP_WORDS[_i]}}"')
    lines.append(f"{i5}else")
    lines.append(f'{i6}_path="${{_path}}/${{COMP_WORDS[_i]}}"')
    lines.append(f"{i5}fi")
    lines.append(f"{i5};;")
    lines.append(f"{i3}esac")
    lines.append(f"{i2}done")
    lines.append(f'{i2}local _try_path="$_path"')
    lines.append(f'{i2}while [[ -n "$_try_path" ]]')
    lines.append(f"{i2}do")
    lines.append(f'{i3}if [[ -n "${{_flags[$_try_path]+x}}" ]]')
    lines.append(f"{i3}then")
    lines.append(f'{i4}local _available="${{_flags[$_try_path]}}"')
    lines.append(f"{i4}for (( _i=1; _i < COMP_CWORD; _i++ ))")
    lines.append(f"{i4}do")
    lines.append(f'{i5}if [[ "${{COMP_WORDS[_i]}}" == --* ]]')
    lines.append(f"{i5}then")
    lines.append(f'{i6}_available="${{_available//${{COMP_WORDS[_i]}}/}}"')
    lines.append(f"{i5}fi")
    lines.append(f"{i4}done")
    lines.append(f"{i4}# shellcheck disable=SC2086")
    lines.append(f"{i4}args+=($_available)")
    lines.append(f"{i4}break")
    lines.append(f"{i3}fi")
    lines.append(f'{i3}local _prev="$_try_path"')
    lines.append(f'{i3}_try_path="${{_try_path%/*}}"')
    lines.append(f'{i3}[[ "$_try_path" == "$_prev" ]] && break')
    lines.append(f"{i2}done")
    lines.append(f"{_I}fi")

    # -- Footer ---------------------------------------------------------------
    lines.append("    # Quoting inside the array doesn't work for Bash, but does for Zsh.")
    lines.append('    COMPREPLY=($(compgen -W "${args[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))')
    lines.append(f"{_I}return 0")
    lines.append("}")
    lines.append("")
    lines.append("complete -F _koopa_complete koopa")
    lines.append("")

    content = "\n".join(lines)
    output_path = os.path.join(koopa_prefix(), "etc", "completion", "koopa.sh")
    with open(output_path, "w") as f:
        f.write(content)
