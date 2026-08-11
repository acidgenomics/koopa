"""Generate the koopa CLI reference published to koopa.acidgenomics.com.

Auto-generates MyST markdown pages under ``docs/reference/`` by reusing the
authoritative command/platform tables from ``generate_completion.py`` and the
descriptions in ``cli_docs.py``. Command names and platform tags are never
duplicated here -- only prose (descriptions, flags) is rendered.

Usage::

    koopa develop generate-docs
"""

import os
from collections.abc import Callable

from koopa.cli_docs import (
    ADMIN_DESCRIPTIONS,
    ADMIN_SYNOPSIS,
    APP_DESCRIPTIONS,
    APP_NAMESPACE_DESCRIPTIONS,
    DEVELOP_DESCRIPTIONS,
    DEVELOP_SYNOPSIS,
    INSTALL_FLAGS,
    REINSTALL_FLAGS,
    RUN_DESCRIPTIONS,
    RUN_SYNOPSIS,
    SYSTEM_DESCRIPTIONS,
    SYSTEM_SYNOPSIS,
    TOP_COMMANDS,
)

# ---------------------------------------------------------------------------
# markdown helpers
# ---------------------------------------------------------------------------


def _anchor(name: str) -> str:
    """Return a slug id usable as an explicit MyST/Sphinx anchor target."""
    return f"koopa-{name.replace(' ', '-')}"


def _entry(name: str, synopsis: str, description: str, *, level: int = 2) -> list[str]:
    """Render one command as a definition-list-style block.

    ``level`` picks the heading depth (2 for a flat page, 3 when nested
    under a namespace H2, as on the app reference page) -- Sphinx's
    ``myst.header`` check requires consecutive levels with no skips.
    """
    term = f"`{name}"
    if synopsis:
        term += f" {synopsis}"
    term += "`"
    lines = [f"({_anchor(name)})=", f"{'#' * level} {term}"]
    if description:
        lines.append("")
        lines.append(description)
    lines.append("")
    return lines


def _flag_table(flags: list[tuple[str, str]]) -> list[str]:
    if not flags:
        return []
    lines = ["| Flag | Description |", "| --- | --- |"]
    for flag, desc in flags:
        lines.append(f"| `{flag}` | {desc} |")
    lines.append("")
    return lines


# ---------------------------------------------------------------------------
# per-surface page builders
# ---------------------------------------------------------------------------


def _render_top_level() -> str:
    lines = ["# Top-level commands", ""]
    for name, synopsis, desc in TOP_COMMANDS:
        lines += _entry(name, synopsis, desc)
    lines.append("## Install options")
    lines.append("")
    lines += _flag_table(INSTALL_FLAGS)
    lines.append("## Reinstall options")
    lines.append("")
    lines += _flag_table(REINSTALL_FLAGS)
    return "\n".join(lines) + "\n"


def _render_system() -> str:
    from koopa.generate_completion import _SYSTEM_COMMANDS, _extract_handler_flags
    from koopa.prefix import python_prefix

    handler_flags = _extract_handler_flags(
        os.path.join(python_prefix(), "src", "koopa", "cli_system.py")
    )
    lines = ["# koopa system", ""]
    common = [n for n, p in _SYSTEM_COMMANDS if p is None]
    macos_only = [n for n, p in _SYSTEM_COMMANDS if p == "macos"]
    for name in common:
        synopsis = SYSTEM_SYNOPSIS.get(name, "")
        lines += _entry(f"system {name}", synopsis, SYSTEM_DESCRIPTIONS.get(name, ""))
        func_name = "_handle_" + name.replace("-", "_")
        for flag in handler_flags.get(func_name, []):
            lines.append(f"- `{flag}`")
        if handler_flags.get(func_name):
            lines.append("")
    if macos_only:
        lines.append("## macOS-only")
        lines.append("")
        for name in macos_only:
            synopsis = SYSTEM_SYNOPSIS.get(name, "")
            lines += _entry(f"system {name}", synopsis, SYSTEM_DESCRIPTIONS.get(name, ""))
    return "\n".join(lines) + "\n"


def _render_admin() -> str:
    from koopa.generate_completion import _ADMIN_COMMANDS

    lines = ["# koopa admin", "", "All commands in this section require sudo.", ""]
    common = [n for n, p in _ADMIN_COMMANDS if p is None]
    linux_only = [n for n, p in _ADMIN_COMMANDS if p == "linux"]
    macos_only = [n for n, p in _ADMIN_COMMANDS if p == "macos"]
    for name in common:
        synopsis = ADMIN_SYNOPSIS.get(name, "")
        lines += _entry(f"admin {name}", synopsis, ADMIN_DESCRIPTIONS.get(name, ""))
    if linux_only:
        lines.append("## Linux-only")
        lines.append("")
        for name in linux_only:
            synopsis = ADMIN_SYNOPSIS.get(name, "")
            lines += _entry(f"admin {name}", synopsis, ADMIN_DESCRIPTIONS.get(name, ""))
    if macos_only:
        lines.append("## macOS-only")
        lines.append("")
        for name in macos_only:
            synopsis = ADMIN_SYNOPSIS.get(name, "")
            lines += _entry(f"admin {name}", synopsis, ADMIN_DESCRIPTIONS.get(name, ""))
    return "\n".join(lines) + "\n"


def _render_develop() -> str:
    from koopa.generate_completion import (
        _extract_handler_flags,
        _extract_handler_key_to_func,
        _load_develop_commands,
    )
    from koopa.prefix import python_prefix

    cli_develop_path = os.path.join(python_prefix(), "src", "koopa", "cli_develop.py")
    key_to_func = _extract_handler_key_to_func(cli_develop_path)
    handler_flags = _extract_handler_flags(cli_develop_path)

    lines = ["# koopa develop", ""]
    for name in _load_develop_commands():
        synopsis = DEVELOP_SYNOPSIS.get(name, "")
        lines += _entry(f"develop {name}", synopsis, DEVELOP_DESCRIPTIONS.get(name, ""))
        func_name = key_to_func.get(name, "")
        for flag in handler_flags.get(func_name, []):
            lines.append(f"- `{flag}`")
        if handler_flags.get(func_name):
            lines.append("")
    return "\n".join(lines) + "\n"


def _render_run() -> str:
    from koopa.cli_bin import _HANDLERS as _RUN_HANDLERS
    from koopa.generate_completion import _extract_handler_flags
    from koopa.prefix import python_prefix

    handler_flags = _extract_handler_flags(
        os.path.join(python_prefix(), "src", "koopa", "cli_bin.py")
    )
    lines = ["# koopa run", ""]
    for name in sorted(_RUN_HANDLERS):
        synopsis = RUN_SYNOPSIS.get(name, "")
        lines += _entry(f"run {name}", synopsis, RUN_DESCRIPTIONS.get(name, ""))
        func_name = "_handle_" + name.replace("-", "_")
        for flag in handler_flags.get(func_name, []):
            lines.append(f"- `{flag}`")
        if handler_flags.get(func_name):
            lines.append("")
    return "\n".join(lines) + "\n"


def _render_app() -> str:
    from koopa.cli_app import _APP_TREE
    from koopa.generate_completion import (
        _extract_handler_flags,
        _extract_handler_key_to_func,
    )
    from koopa.prefix import python_prefix

    cli_app_path = os.path.join(python_prefix(), "src", "koopa", "cli_app.py")
    key_to_func = _extract_handler_key_to_func(cli_app_path)
    handler_flags = _extract_handler_flags(cli_app_path)

    lines = ["# koopa app", ""]
    for namespace in sorted(_APP_TREE):
        lines.append(f"## {namespace}")
        lines.append("")
        desc = APP_NAMESPACE_DESCRIPTIONS.get(namespace, "")
        if desc:
            lines.append(desc)
            lines.append("")
        for path, handler_key in sorted(_flatten_app_namespace(_APP_TREE[namespace])):
            full_name = f"app {namespace} {path}" if path else f"app {namespace}"
            lines += _entry(full_name, "", APP_DESCRIPTIONS.get(handler_key, ""), level=3)
            func_name = key_to_func.get(handler_key, "")
            for flag in handler_flags.get(func_name, []):
                lines.append(f"- `{flag}`")
            if handler_flags.get(func_name):
                lines.append("")
    return "\n".join(lines) + "\n"


def _flatten_app_namespace(node: str | dict, prefix: str = "") -> list[tuple[str, str]]:
    """Flatten one _APP_TREE namespace subtree into (subpath, handler_key) pairs."""
    if isinstance(node, str):
        return [(prefix, node)]
    result: list[tuple[str, str]] = []
    for key, value in node.items():
        sub_prefix = f"{prefix} {key}".strip()
        result.extend(_flatten_app_namespace(value, sub_prefix))
    return result


def _render_index() -> str:
    return "\n".join(
        [
            "# CLI reference",
            "",
            "Every `koopa` command, grouped by surface.",
            "",
            "```{toctree}",
            ":maxdepth: 1",
            "",
            "top-level",
            "system",
            "admin",
            "develop",
            "run",
            "app",
            "```",
            "",
        ]
    )


# ---------------------------------------------------------------------------
# entry point
# ---------------------------------------------------------------------------

_PAGES: dict[str, Callable[[], str]] = {
    "index.md": _render_index,
    "top-level.md": _render_top_level,
    "system.md": _render_system,
    "admin.md": _render_admin,
    "develop.md": _render_develop,
    "run.md": _render_run,
    "app.md": _render_app,
}


def generate_docs() -> None:
    """Regenerate all docs/reference/ pages."""
    from koopa.prefix import koopa_prefix

    out_dir = os.path.join(koopa_prefix(), "docs", "reference")
    os.makedirs(out_dir, exist_ok=True)
    for filename, render in _PAGES.items():
        content = render()
        with open(os.path.join(out_dir, filename), "w", encoding="utf-8") as fh:
            fh.write(content)
