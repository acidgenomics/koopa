"""Generate shell TAB completion files for koopa.

Auto-generates per-shell completion files from the Python dispatch tables,
``app.json``, and AST-extracted argparse flags.

Output files:
    share/bash-completion/completions/koopa
    share/fish/vendor_completions.d/koopa.fish
    share/zsh/site-functions/_koopa
    share/powershell/completions/koopa.ps1

Usage::

    koopa develop generate-completion
"""

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
    ("hostname", None),
    ("info", None),
    ("list", None),
    ("os-string", None),
    ("prefix", None),
    ("prune-apps", None),
    ("switch-to-develop", None),
    ("version", None),
    ("which", None),
]

_ADMIN_COMMANDS: list[tuple[str, str | None]] = [
    ("disable-passwordless-sudo", None),
    ("enable-passwordless-sudo", None),
    ("zsh-compaudit-set-permissions", None),
    ("delete-cache", "linux"),
    ("fix-sudo-setrlimit-error", "linux"),
    ("clean-launch-services", "macos"),
    ("disable-touch-id-sudo", "macos"),
    ("enable-touch-id-sudo", "macos"),
    ("flush-dns", "macos"),
    ("force-eject", "macos"),
    ("reload-autofs", "macos"),
]

_SYSTEM_LIST: list[tuple[str, str | None]] = [
    ("app-versions", None),
    ("path-priority", None),
    ("launch-agents", "macos"),
]


def _get_main_command_flags() -> dict[str, list[str]]:
    """Derive flags for top-level subcommands from argparse parser."""
    import argparse

    from koopa.cli_main import _build_parser

    parser = _build_parser()
    subparsers_action = next(
        a for a in parser._actions if isinstance(a, argparse._SubParsersAction)
    )
    result: dict[str, list[str]] = {}
    for name, subparser in subparsers_action.choices.items():
        if name not in _TOP_CMDS:
            continue
        flags = ["--help"]
        for action in subparser._actions:
            for opt in action.option_strings:
                if opt.startswith("--"):
                    flags.append(opt)
        if flags:
            result[name] = sorted(set(flags))
    # Manual flag parsing not detectable via argparse introspection.
    result["develop/format-app-json"] = ["--help", "--prettier"]
    result["develop/remove-app"] = ["--help", "--revdeps"]
    return result


def _get_installer_mode_apps() -> dict[str, list[tuple[str, str | None]]]:
    """Derive install/update subcommands from installer modes registry."""
    from koopa.installers import PYTHON_INSTALLER_MODES, PYTHON_PLATFORM_INSTALLERS

    result: dict[str, list[tuple[str, str | None]]] = {
        "system-install": [],
        "system": [],
        "user": [],
        "update-system": [],
    }
    for name, platform, mode in PYTHON_INSTALLER_MODES:
        plat: str | None = None if platform == "common" else platform
        result[mode].append((name, plat))
    for name, platform, mode in PYTHON_PLATFORM_INSTALLERS:
        if mode == "system":
            plat: str | None = None if platform == "common" else platform
            result["system"].append((name, plat))
    return result


def _get_private_apps() -> list[tuple[str, str | None]]:
    """Derive private app list from app.json."""
    from koopa.io import import_app_json

    data = import_app_json()
    result: list[tuple[str, str | None]] = []
    for name, meta in sorted(data.items()):
        if meta.get("private"):
            plat = meta.get("installer_platform")
            result.append((name, plat))
    return result


def _get_configure_apps() -> tuple[list[tuple[str, str | None]], list[tuple[str, str | None]]]:
    """Derive configure subcommands from PYTHON_CONFIGURERS registry."""
    from koopa.configurers import PYTHON_CONFIGURERS

    system_apps: list[tuple[str, str | None]] = []
    user_apps: list[tuple[str, str | None]] = []
    seen_system: set[str] = set()
    seen_user: set[str] = set()
    for name, platform, mode in PYTHON_CONFIGURERS:
        plat: str | None = None if platform == "common" else platform
        if mode in ("system", "shared"):
            if name not in seen_system:
                seen_system.add(name)
                system_apps.append((name, plat))
        elif mode == "user" and name not in seen_user:
            seen_user.add(name)
            user_apps.append((name, plat))
    return system_apps, user_apps


# ---------------------------------------------------------------------------
# Data loaders
# ---------------------------------------------------------------------------


def _load_app_tree() -> dict[str, Any]:
    from koopa.cli_app import _APP_TREE

    return _APP_TREE


def _load_develop_commands() -> list[str]:
    from koopa.cli_develop import _DEVELOP_HANDLERS

    return sorted(_DEVELOP_HANDLERS.keys())


def _load_run_commands() -> list[str]:
    from koopa.cli_bin import _HANDLERS

    return sorted(_HANDLERS.keys())


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
# Fish completion generator
# ---------------------------------------------------------------------------

_TOP_CMDS = [
    "admin",
    "app",
    "configure",
    "develop",
    "install",
    "list",
    "reinstall",
    "run",
    "system",
    "uninstall",
    "update",
]

_TOP_CMD_DESCS = {
    "admin": "System administration (requires sudo)",
    "app": "Application management",
    "configure": "Configure system",
    "develop": "Development utilities",
    "install": "Install apps",
    "list": "List available apps",
    "reinstall": "Reinstall an app",
    "run": "Run a utility command",
    "system": "System information and management",
    "uninstall": "Uninstall an app",
    "update": "Update installed apps",
}


def _generate_fish_completion(
    app_tree: dict[str, Any],
    develop_cmds: list[str],
    common_apps: list[str],
    linux_apps: list[str],
    macos_apps: list[str],
    flag_map: dict[str, list[str]],
    today: str,
) -> str:
    """Generate fish shell completion for koopa."""
    lines: list[str] = []
    top_seen = " ".join(_TOP_CMDS)
    app_ns = sorted(app_tree.keys())
    app_ns_seen = " ".join(app_ns)

    lines += [
        "#!/usr/bin/env fish",
        "# Koopa fish shell completions.",
        f"# @note Updated {today}.",
        "# @note Auto-generated by 'koopa develop generate-completion'.",
        "",
        "complete -c koopa -f",
        "",
        "# Level 1: top-level flags.",
        f"complete -c koopa -n 'not __fish_seen_subcommand_from {top_seen}' -l help -d 'Show help'",
        "complete -c koopa -n 'not __fish_seen_subcommand_from"
        f" {top_seen}' -l version -d 'Show version'",
        "",
        "# Level 1: top-level subcommands.",
    ]
    for cmd in _TOP_CMDS:
        desc = _TOP_CMD_DESCS.get(cmd, "")
        desc_part = f" -d '{desc}'" if desc else ""
        lines.append(
            f"complete -c koopa -n 'not __fish_seen_subcommand_from"
            f" {top_seen}' -a '{cmd}'{desc_part}"
        )

    lines += ["", "# Level 2: app subcommands."]
    for ns in app_ns:
        lines.append(
            f"complete -c koopa"
            f" -n '__fish_seen_subcommand_from app;"
            f" and not __fish_seen_subcommand_from {app_ns_seen}'"
            f" -a '{ns}'"
        )

    lines += ["", "# Level 3+: app sub-subcommands."]
    for ns, val in sorted(app_tree.items()):
        if not isinstance(val, dict):
            continue
        sub_cmds = sorted(val.keys())
        sub_seen = " ".join(sub_cmds)
        lines.append(f"# app {ns}")
        for sub in sub_cmds:
            lines.append(
                f"complete -c koopa"
                f" -n '__fish_seen_subcommand_from app;"
                f" and __fish_seen_subcommand_from {ns};"
                f" and not __fish_seen_subcommand_from {sub_seen}'"
                f" -a '{sub}'"
            )
            sub_val = val[sub]
            if isinstance(sub_val, dict):
                for leaf in sorted(sub_val.keys()):
                    lines.append(
                        f"complete -c koopa"
                        f" -n '__fish_seen_subcommand_from app;"
                        f" and __fish_seen_subcommand_from {ns};"
                        f" and __fish_seen_subcommand_from {sub}'"
                        f" -a '{leaf}'"
                    )

    dev_seen = " ".join(develop_cmds)
    lines += ["", "# develop subcommands."]
    for cmd in develop_cmds:
        lines.append(
            f"complete -c koopa"
            f" -n '__fish_seen_subcommand_from develop;"
            f" and not __fish_seen_subcommand_from {dev_seen}'"
            f" -a '{cmd}'"
        )

    run_cmds = _load_run_commands()
    run_seen = " ".join(run_cmds)
    lines += ["", "# run subcommands."]
    for cmd in run_cmds:
        lines.append(
            f"complete -c koopa"
            f" -n '__fish_seen_subcommand_from run;"
            f" and not __fish_seen_subcommand_from {run_seen}'"
            f" -a '{cmd}'"
        )

    system_cmds = sorted(e[0] for e in _SYSTEM_COMMANDS)
    system_seen = " ".join(system_cmds)
    lines += ["", "# system subcommands."]
    for cmd in system_cmds:
        lines.append(
            f"complete -c koopa"
            f" -n '__fish_seen_subcommand_from system;"
            f" and not __fish_seen_subcommand_from {system_seen}'"
            f" -a '{cmd}'"
        )

    admin_cmds = sorted(e[0] for e in _ADMIN_COMMANDS)
    admin_seen = " ".join(admin_cmds)
    lines += ["", "# admin subcommands."]
    for cmd in admin_cmds:
        lines.append(
            f"complete -c koopa"
            f" -n '__fish_seen_subcommand_from admin;"
            f" and not __fish_seen_subcommand_from {admin_seen}'"
            f" -a '{cmd}'"
        )

    all_apps = sorted(set(common_apps + linux_apps + macos_apps))
    lines += ["", "# install/reinstall/uninstall: app names."]
    for install_cmd in ("install", "reinstall", "uninstall"):
        for app in all_apps:
            lines.append(
                f"complete -c koopa -n '__fish_seen_subcommand_from {install_cmd}' -a '{app}'"
            )

    lines += ["", "# update: mode completions."]
    for mode in ("koopa", "system", "user"):
        lines.append(f"complete -c koopa -n '__fish_seen_subcommand_from update' -a '{mode}'")

    lines += ["", "# Per-command flag completions."]
    for path_key in sorted(flag_map):
        parts = path_key.split("/")
        flags = flag_map[path_key]
        conditions = " and ".join(f"__fish_seen_subcommand_from {p}" for p in parts)
        condition = f"'{conditions}'"
        for flag in sorted(flags):
            long_name = flag.lstrip("-")
            lines.append(f"complete -c koopa -n {condition} -l {long_name}")

    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Zsh native completion generator
# ---------------------------------------------------------------------------


def _zsh_app_namespace_completions(
    app_tree: dict[str, Any],
    lines: list[str],
) -> None:
    """Generate per-namespace sub-dispatchers for zsh completion."""
    for ns, val in sorted(app_tree.items()):
        if not isinstance(val, dict):
            continue
        fn = ns.replace("-", "_")
        sub_cmds = sorted(val.keys())
        has_deep = any(isinstance(val[s], dict) for s in sub_cmds)

        if has_deep:
            lines += [
                f"_koopa_app_{fn}() {{",
                "    local context state line",
                "    typeset -A opt_args",
                "    _arguments -C \\",
                f"        '1: :_koopa_app_{fn}_cmds' \\",
                "        '*:: :->subcmd'",
                "    [[ $state == subcmd ]] || return 0",
                "    case $words[1] in",
            ]
            for sub in sub_cmds:
                sub_fn = sub.replace("-", "_")
                if isinstance(val[sub], dict):
                    lines.append(f"        {sub}) _koopa_app_{fn}_{sub_fn} ;;")
                else:
                    lines.append(f"        {sub}) return 0 ;;")
            lines += ["    esac", "}", ""]
        else:
            lines += [
                f"_koopa_app_{fn}() {{",
                "    local -a cmds",
                "    cmds=(",
            ]
            for sub in sub_cmds:
                lines.append(f"        '{sub}'")
            lines += [
                "    )",
                f"    _describe -t commands '{ns} command' cmds",
                "}",
                "",
            ]

        if has_deep:
            lines += [f"_koopa_app_{fn}_cmds() {{", "    local -a cmds", "    cmds=("]
            for sub in sub_cmds:
                lines.append(f"        '{sub}'")
            lines += [
                "    )",
                f"    _describe -t commands '{ns} command' cmds",
                "}",
                "",
            ]

        for sub, sub_val in sorted(val.items()):
            if not isinstance(sub_val, dict):
                continue
            sub_fn = str(sub).replace("-", "_")
            leaves = sorted(sub_val.keys())
            lines += [
                f"_koopa_app_{fn}_{sub_fn}() {{",
                "    local -a cmds",
                "    cmds=(",
            ]
            for leaf in leaves:
                lines.append(f"        '{leaf}'")
            lines += [
                "    )",
                f"    _describe -t commands '{ns} {sub} command' cmds",
                "}",
                "",
            ]


def _zsh_subcmd_completion(
    subcmd: str,
    cmds: list[str],
    flag_map: dict[str, list[str]],
    lines: list[str],
) -> None:
    """Generate zsh completion for a subcommand group (develop/run)."""
    flags = {k.split("/", 1)[1]: v for k, v in flag_map.items() if k.startswith(f"{subcmd}/")}
    if flags:
        lines += [
            f"_koopa_{subcmd}() {{",
            "    local context state line",
            "    typeset -A opt_args",
            "    _arguments -C \\",
            f"        '1: :_koopa_{subcmd}_cmds' \\",
            "        '*:: :->subcmd'",
            "    [[ $state == subcmd ]] || return 0",
            "    case $words[1] in",
        ]
        for cmd in sorted(flags):
            flags_str = " ".join(f"'*{f}[{f}]'" for f in sorted(flags[cmd]))
            lines.append(f"        {cmd}) _arguments {flags_str} ;;")
        lines += ["    esac", "}", ""]
        lines += [f"_koopa_{subcmd}_cmds() {{", "    local -a cmds", "    cmds=("]
        for cmd in cmds:
            lines.append(f"        '{cmd}'")
        lines += [
            "    )",
            f"    _describe -t commands '{subcmd} command' cmds",
            "}",
            "",
        ]
    else:
        lines += [f"_koopa_{subcmd}() {{", "    local -a cmds", "    cmds=("]
        for cmd in cmds:
            lines.append(f"        '{cmd}'")
        lines += ["    )", f"    _describe -t commands '{subcmd} command' cmds", "}", ""]


def _generate_zsh_completion(
    app_tree: dict[str, Any],
    develop_cmds: list[str],
    common_apps: list[str],
    linux_apps: list[str],
    macos_apps: list[str],
    flag_map: dict[str, list[str]],
    today: str,
) -> str:
    """Generate native zsh completion for koopa using _arguments/_describe."""
    lines: list[str] = []
    app_ns = sorted(app_tree.keys())
    all_apps = sorted(set(common_apps + linux_apps + macos_apps))

    lines += [
        "#compdef koopa",
        "# Koopa zsh completions.",
        f"# @note Updated {today}.",
        "# @note Auto-generated by 'koopa develop generate-completion'.",
        "",
    ]

    # -- Main dispatcher ------------------------------------------------------
    lines += [
        "_koopa() {",
        "    local context state line",
        "    typeset -A opt_args",
        "    _arguments -C \\",
        "        '(- :)--help[Show help]' \\",
        "        '(- :)--version[Show version]' \\",
        "        '1: :_koopa_cmds' \\",
        "        '*:: :->subcmd'",
        "    [[ $state == subcmd ]] || return 0",
        "    case $words[1] in",
    ]
    for cmd in _TOP_CMDS:
        if cmd == "app":
            lines.append(f"        {cmd}) _koopa_app ;;")
        elif cmd == "develop":
            lines.append(f"        {cmd}) _koopa_develop ;;")
        elif cmd == "run":
            lines.append(f"        {cmd}) _koopa_run ;;")
        elif cmd in ("install", "reinstall", "uninstall"):
            lines.append(f"        {cmd}) _koopa_install ;;")
        elif cmd == "update":
            lines.append(f"        {cmd}) _koopa_update ;;")
        else:
            lines.append(f"        {cmd}) return 0 ;;")
    lines += ["    esac", "}", ""]

    # -- Top-level commands ---------------------------------------------------
    lines += ["_koopa_cmds() {", "    local -a cmds", "    cmds=("]
    for cmd in _TOP_CMDS:
        desc = _TOP_CMD_DESCS.get(cmd, "")
        lines.append(f"        '{cmd}:{desc}'")
    lines += ["    )", "    _describe -t commands 'koopa command' cmds", "}", ""]

    # -- app dispatcher -------------------------------------------------------
    lines += [
        "_koopa_app() {",
        "    local context state line",
        "    typeset -A opt_args",
        "    _arguments -C \\",
        "        '1: :_koopa_app_cmds' \\",
        "        '*:: :->subcmd'",
        "    [[ $state == subcmd ]] || return 0",
        "    case $words[1] in",
    ]
    for ns in app_ns:
        val = app_tree[ns]
        fn = ns.replace("-", "_")
        if isinstance(val, dict):
            lines.append(f"        {ns}) _koopa_app_{fn} ;;")
        else:
            lines.append(f"        {ns}) return 0 ;;")
    lines += ["    esac", "}", ""]

    # -- app namespace list ---------------------------------------------------
    lines += ["_koopa_app_cmds() {", "    local -a cmds", "    cmds=("]
    for ns in app_ns:
        lines.append(f"        '{ns}'")
    lines += ["    )", "    _describe -t commands 'app command' cmds", "}", ""]

    # -- per-namespace sub-dispatchers ----------------------------------------
    _zsh_app_namespace_completions(app_tree, lines)

    # -- develop --------------------------------------------------------------
    _zsh_subcmd_completion("develop", develop_cmds, flag_map, lines)

    # -- run ------------------------------------------------------------------
    run_cmds = _load_run_commands()
    _zsh_subcmd_completion("run", run_cmds, flag_map, lines)

    # -- install/reinstall/uninstall ------------------------------------------
    lines += ["_koopa_install() {", "    local -a apps", "    apps=("]
    for app in all_apps:
        lines.append(f"        '{app}'")
    lines += ["    )", "    _describe -t apps 'app name' apps", "}", ""]

    # -- update ---------------------------------------------------------------
    update_flags_zsh = sorted(flag_map.get("update", []))
    lines += ["_koopa_update() {", "    _arguments \\"]
    for flag in update_flags_zsh:
        lines.append(f"        '{flag}[{flag}]' \\")
    lines += ["        '1:mode:(koopa system user)'", "}", ""]

    lines.append('_koopa "$@"')
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# PowerShell completion generator
# ---------------------------------------------------------------------------


def _ps_array(items: list[str]) -> str:
    """Format a list as a PowerShell array of single-quoted strings."""
    return ", ".join(f"'{item}'" for item in items)


def _generate_powershell_completion(
    app_tree: dict[str, Any],
    develop_cmds: list[str],
    common_apps: list[str],
    linux_apps: list[str],
    macos_apps: list[str],
    flag_map: dict[str, list[str]],
    today: str,
) -> str:
    """Generate PowerShell tab completion for koopa via Register-ArgumentCompleter."""
    lines: list[str] = []
    app_ns = sorted(app_tree.keys())
    all_apps = sorted(set(common_apps + linux_apps + macos_apps))
    top_cmds = sorted(_TOP_CMDS)
    _system_cmds_ps = _ps_array(sorted(e[0] for e in _SYSTEM_COMMANDS if e[1] is None))
    _admin_cmds_ps = _ps_array(sorted(e[0] for e in _ADMIN_COMMANDS if e[1] is None))

    lines += [
        "# Koopa PowerShell completions.",
        f"# @note Updated {today}.",
        "# @note Auto-generated by 'koopa develop generate-completion'.",
        "",
        "Register-ArgumentCompleter -Native -CommandName koopa -ScriptBlock {",
        "    param($wordToComplete, $commandAst, $cursorPosition)",
        "",
        "    # Collect completed tokens (skip 'koopa' and the word being typed).",
        "    $all = @($commandAst.CommandElements | ForEach-Object { $_.ToString() })",
        "    $tokens = if ($wordToComplete -and $all.Count -gt 1 -and $all[-1] -eq $wordToComplete) {",  # noqa: E501
        "        $all[1..($all.Count - 2)]",
        "    } else {",
        "        $all | Select-Object -Skip 1",
        "    }",
        "    $depth = $tokens.Count",
        "    $completions = @()",
        "",
        "    switch ($depth) {",
        "        0 {",
        f"            $completions = @({_ps_array(['--help', '--version', *top_cmds])})",
        "        }",
        "        1 {",
        "            switch ($tokens[0]) {",
        f"                'admin'     {{ $completions = @({_admin_cmds_ps}) }}",
        f"                'app'       {{ $completions = @({_ps_array(app_ns)}) }}",
        "                'configure' { $completions = @('system', 'user') }",
        f"                'develop'   {{ $completions = @({_ps_array(develop_cmds)}) }}",
        f"                'run'       {{ $completions = @({_ps_array(_load_run_commands())}) }}",
        f"                'install'   {{ $completions = @({_ps_array(all_apps)}) }}",
        f"                'reinstall' {{ $completions = @({_ps_array(all_apps)}) }}",
        f"                'uninstall' {{ $completions = @({_ps_array(all_apps)}) }}",
        f"                'system'    {{ $completions = @({_system_cmds_ps}) }}",
        f"                'update'    {{ $completions = @("
        f"{_ps_array(['koopa', 'system', 'user'])}) }}",
        "            }",
        "        }",
        "        2 {",
        "            if ($tokens[0] -eq 'app') {",
        "                switch ($tokens[1]) {",
    ]

    # depth=2: app namespace -> subcommands
    for ns, val in sorted(app_tree.items()):
        if isinstance(val, dict):
            children = sorted(val.keys())
            lines.append(
                f"                    '{ns}' {{ $completions = @({_ps_array(children)}) }}"
            )

    lines += [
        "                }",
        "            }",
        "        }",
        "        3 {",
        "            if ($tokens[0] -eq 'app') {",
        "                switch ($tokens[1]) {",
    ]

    # depth=3: app namespace -> sub -> sub-subcommands
    for ns, val in sorted(app_tree.items()):
        if not isinstance(val, dict):
            continue
        # Only emit if the sub-namespace has its own dict children.
        deep_subs = {sub: sub_val for sub, sub_val in val.items() if isinstance(sub_val, dict)}
        if not deep_subs:
            continue
        lines.append(f"                    '{ns}' {{")
        lines.append("                        switch ($tokens[2]) {")
        for sub, sub_val in sorted(deep_subs.items()):
            leaves = sorted(sub_val.keys())
            lines.append(
                f"                            '{sub}' {{ $completions = @({_ps_array(leaves)}) }}"
            )
        lines.append("                        }")
        lines.append("                    }")

    lines += [
        "                }",
        "            }",
        "        }",
        "    }",
        "",
        "    # Flag completion: when the current word starts with '--'.",
        "    if ($wordToComplete -like '--*') {",
        "        $path = ($tokens -join '/')",
        "        $flagMap = @{",
    ]
    for path_key in sorted(flag_map):
        flags_str = _ps_array(sorted(flag_map[path_key]))
        lines.append(f"            '{path_key}' = @({flags_str})")
    lines += [
        "        }",
        "        if ($flagMap.ContainsKey($path)) {",
        "            $completions = $flagMap[$path]",
        "        }",
        "    }",
        "",
        '    $completions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {',
        "        [System.Management.Automation.CompletionResult]::new(",
        "            $_, $_, 'ParameterValue', $_)",
        "    }",
        "}",
        "",
    ]
    return "\n".join(lines)


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
    flag_map.update(_get_main_command_flags())

    installer_modes = _get_installer_mode_apps()
    private_apps = _get_private_apps()
    configure_system, configure_user = _get_configure_apps()

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
                "admin",
                "app",
                "configure",
                "develop",
                "install",
                "list",
                "reinstall",
                "run",
                "system",
                "uninstall",
                "update",
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

    # run
    run_cmds = _load_run_commands()
    lines.extend(
        _emit_case_entry(
            "'run')",
            _emit_args_array(run_cmds, i5),
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
    install_body.append(f"{i6}{_I}args+=('system' 'user')")
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

    # admin
    lines.extend(
        _emit_case_entry(
            "'admin')",
            _emit_platform_block(_ADMIN_COMMANDS, i5),
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
    update_items = ["koopa", "system", "user"]
    update_items_str = " ".join(f"'{x}'" for x in update_items)
    lines.extend(
        _emit_case_entry(
            "'update')",
            [f"{i5}args+=({update_items_str})"],
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
            _emit_platform_block(configure_system, i6 + _I),
            i6,
        )
    )
    lines.extend(
        _emit_case_entry(
            "'user')",
            _emit_platform_block(configure_user, i6 + _I),
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
            _emit_platform_block(installer_modes["system-install"], i6 + _I * 3 + _I),
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
            _emit_platform_block(private_apps, i6 + _I),
            i6,
        )
    )
    lines.extend(
        _emit_case_entry(
            "'system')",
            _emit_platform_block(installer_modes["system"], i6 + _I),
            i6,
        )
    )
    lines.extend(
        _emit_case_entry(
            "'user')",
            _emit_platform_block(installer_modes["user"], i6 + _I),
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
            _emit_platform_block(installer_modes["update-system"], i6 + _I),
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

    # Write bash completion to the central bash-completion directory.
    bash_path = os.path.join(koopa_prefix(), "share", "bash-completion", "completions", "koopa")
    os.makedirs(os.path.dirname(bash_path), exist_ok=True)
    with open(bash_path, "w") as f:
        f.write(content)

    # Write fish completion.
    fish_content = _generate_fish_completion(
        app_tree, develop_cmds, common_apps, linux_apps, macos_apps, flag_map, today
    )
    fish_path = os.path.join(koopa_prefix(), "share", "fish", "vendor_completions.d", "koopa.fish")
    os.makedirs(os.path.dirname(fish_path), exist_ok=True)
    with open(fish_path, "w") as f:
        f.write(fish_content)

    # Write zsh native completion.
    zsh_content = _generate_zsh_completion(
        app_tree, develop_cmds, common_apps, linux_apps, macos_apps, flag_map, today
    )
    zsh_path = os.path.join(koopa_prefix(), "share", "zsh", "site-functions", "_koopa")
    os.makedirs(os.path.dirname(zsh_path), exist_ok=True)
    with open(zsh_path, "w") as f:
        f.write(zsh_content)

    # Write PowerShell completion.
    ps_content = _generate_powershell_completion(
        app_tree, develop_cmds, common_apps, linux_apps, macos_apps, flag_map, today
    )
    ps_path = os.path.join(koopa_prefix(), "share", "powershell", "completions", "koopa.ps1")
    os.makedirs(os.path.dirname(ps_path), exist_ok=True)
    with open(ps_path, "w") as f:
        f.write(ps_content)
