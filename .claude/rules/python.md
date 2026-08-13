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

## Python-version floor vs. runtime version

`[tool.ruff] target-version` (currently `py312`) is **not** the same thing as
`requires-python`/`tool.pyright.pythonVersion` (currently `3.14`), and it must
stay behind them. `koopa update` is the only path that installs a new pinned
Python, and it runs under the *outgoing* interpreter until it finishes
rebuilding bootstrap — so koopa's own source has to stay parseable and
importable on that older version, not just on the new pin. Bumping
`target-version` to match a fresh `.python-version` bricks every host still
on the old one: `koopa --version` and `koopa update` both fail to import
before they ever reach the code that would upgrade them.

Two traps neither look version-sensitive at a glance, and ruff at the right
`target-version` catches both:

- **PEP 758** (3.14): unparenthesized `except A, B:` is a syntax error before
  3.14. Always write `except (A, B):`.
- **PEP 649** (3.14): annotations are evaluated lazily. An unquoted forward
  reference (`x: Foo | None` where `Foo` is defined later in the module, or
  `-> Foo:` where `Foo` is only imported under `if TYPE_CHECKING:`) is a
  `NameError` at import time on 3.13 and earlier. Quote it (`x: "Foo | None"`,
  `-> "Foo":`) instead of moving the class or hoisting the import.

`ruff check lang/python/src/` catches PEP 758 reliably, but **not** the
`TYPE_CHECKING` form of the PEP 649 trap -- ruff treats a name imported only
under `if TYPE_CHECKING:` as valid in an unquoted annotation regardless of
`target-version`, since that guard is normally paired with
`from __future__ import annotations` (which koopa does not use). The only
reliable check is actually importing every module under the floor
interpreter:
```sh
PYTHONPATH=lang/python/src <floor-python> -c "
import importlib, pkgutil, koopa
for m in pkgutil.walk_packages(koopa.__path__, prefix='koopa.'):
    importlib.import_module(m.name)
"
```
This caught two instances (`cli_main.py`, `installers/_build_helper.py`) that
`ruff check` reported as clean.

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
