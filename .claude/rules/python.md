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

## CLI dispatch tiers

koopa has three tiers; pick the lightest one that fits:

| Tier | Invocation | Register in | When to use |
|---|---|---|---|
| `koopa run X` | `koopa run reset-terminal` | `cli_bin.py:_HANDLERS` | Self-contained utility; no group needed; auto-discovered by completions |
| `koopa system X` | `koopa system info` | `cli_system.py:handle_system` | System-info / admin ops that don't fit the install/configure/develop groups |
| Top-level `koopa X` | `koopa install` | `cli_main.py:_build_parser` + `handlers` dict + `_TOP_CMDS` in 8 places in `generate_completion.py` | Major lifecycle commands only; adding one is invasive |

Default to `koopa run` for new utilities — zero parser changes, completion
auto-discovers via `_load_run_commands()` reading `_HANDLERS.keys()`.

## CLI completions

Adding, renaming, or removing a CLI command in `cli_*.py` requires running
`koopa develop generate-completion` afterward — completions are generated, not
hand-maintained.

## Color-mode apply paths

`configurers/dotfiles.py`, `configurers/color_mode.py`, `opt/dotfiles/install`:
- Derive `KOOPA_COLOR_MODE` from `os_appearance_mode()` at apply time — never from
  `os.environ` (session env is stale in long-running processes).
- Re-apply all trees in order: main → work → private. Each non-main tree needs its
  own `--config=<prefix>/chezmoi.toml` when that file exists — the work tree sets a
  non-default `persistentState` (and age encryption), so omitting `--config` reads
  the wrong state DB. `color_mode.py` applies each tree independently (own
  discovery, own `chezmoi managed` probe, own `--config`); it never delegates to
  `dotfiles.py`'s `main()` and never invokes any tree's `install` script.
- A discovered `chezmoi apply` target must be filtered against `_chezmoi_managed()`
  output, never `os.path.exists()`. `chezmoi apply` aborts entirely if any one
  target argument is unmanaged — one `.chezmoiignore`'d-but-on-disk file blocks
  every other target in the same call. In a multi-tree apply, warn about a
  dropped target only once no tree has claimed it — a target one tree drops may
  be legitimately managed by a later tree.

See skill `koopa-color-mode` for full context.
