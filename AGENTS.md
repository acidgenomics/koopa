# Agent Instructions for koopa

Shell bootloader for data science. A comprehensive Python toolkit for system
administration, bioinformatics, and development environment management.

## Build, Test, and Lint

### Running Tests

```sh
pytest lang/python/tests/
```

### Linting and Formatting

```sh
ruff check lang/python/src/
ruff format lang/python/src/
```

### Type Checking

```sh
pyright lang/python/src/
```

## Architecture

```
lang/python/
├── src/koopa/
│   ├── cli_*.py          # CLI command dispatchers
│   ├── installers/       # Installation routines for packages/tools
│   ├── configurers/      # System configuration modules
│   ├── system.py         # System platform detection
│   └── [utility modules]
└── tests/
    └── test_*.py
```

- `etc/koopa/app.json` — central app registry (version, default, installer).
  Edit freely; run `koopa develop format-app-json` after changes; bump `revision`.
- Dotfiles: chezmoi-managed, source at `opt/dotfiles/chezmoi/`. Always edit the
  source file, never the deployed copy under `~`.
- Platform: macOS arm64 and Linux x86_64/arm64. Intel Mac not supported.
- Line length: 100 chars. Python 3.14+. NumPy-style docstrings.

## Key Conventions

- Never commit or push — leave version control to the user.
- Never install packages or add dependencies without being asked.
- Never suppress linting errors with `# noqa` — fix the underlying code.
- Use `subprocess.run(..., check=True)` — never `check=False`.
- XDG base dirs: use `from koopa.xdg import xdg_config_home, xdg_data_home`
  — never hardcode `~/.config` or `~/.local/share`.

## Global Behavior Rules

See `~/.gemini/GEMINI.md` (Antigravity CLI / `agy`) or `~/.codex/AGENTS.md`
(Codex) for global interaction style, thinking rules, coding standards, and
security rules that apply across all projects.
