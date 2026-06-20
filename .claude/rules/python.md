---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
---

# koopa Python Conventions

These are koopa-specific rules. Generic Python style (PEP 8, type hints) is covered
by the user-global `~/.claude/rules/python.md`.

## subprocess

Always `subprocess.run(..., check=True)`. Never `check=False` — ruff warns `PLW1510`.
The correct fix is always `check=True`, not `check=False` and not suppressing the warning.

## Sudo checks

`koopa.system.has_sudo()` is the single function for checking passwordless sudo.
Do not add new helpers (`_has_sudo`, `can_sudo`, `check_sudo`, etc.) — import and
reuse `has_sudo` from `koopa.system`.

## Dev tools

Tools like `ruff`, `ty`, `pyright`, `pytest` are standalone koopa apps installed
to PATH — NOT dependencies in `.venv` or `[project.optional-dependencies]`.
Never suggest adding them via `uv pip install` into the venv.

## XDG base directories

Use `from koopa.xdg import xdg_config_home, xdg_data_home` — never hardcode
`~/.config` or `~/.local/share`. In standalone scripts (no koopa import):
```python
xdg_config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
```

## CLI completions

Adding, renaming, or removing a CLI command in `cli_*.py` requires running
`koopa develop generate-completion` afterward — completions are generated, not
hand-maintained.

## Color-mode apply paths

`configurers/dotfiles.py`, `configurers/color_mode.py`, `opt/dotfiles/install`:
- Derive `KOOPA_COLOR_MODE` from `os_appearance_mode()` at apply time — never from
  `os.environ` (session env is stale in long-running processes).
- Re-apply all trees in order: main → work → private.

See skill `koopa-color-mode` for full context.
