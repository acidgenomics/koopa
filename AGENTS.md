# Agent Instructions for koopa

Shell bootloader for data science. A comprehensive Python toolkit for system
administration, bioinformatics, and development environment management.

## Build, Test, and Lint

### Full Gate

```sh
koopa develop check
```

Runs every check below in one command: `agent config`, `ruff check`,
`ruff format --check`, `pyright`, `ty check`, `numpydoc`, then `pytest`.
Phases run in cheap-to-expensive order and stop at the first failure, so a
fast lint error fails in seconds instead of waiting for pytest. A passing
phase's output is hidden; the failing phase prints its full output before
the gate raises.

`.githooks/pre-push` runs this gate before every `git push`, through the
machine's global git hook. Skip once with `KOOPA_NO_PUSH_CHECK=1 git push`.
Avoid `--no-verify`: it also skips the global corporate-identity guard.

### Running Tests

```sh
pytest lang/python/tests/
```

### Linting and Formatting

```sh
ruff check lang/python/src/
ruff format --check lang/python/src/
```

Use `ruff format` (no `--check`) only to apply fixes, not to verify the gate.

### Type Checking

```sh
pyright lang/python/src/
ty check lang/python/src/koopa
```

### Docstring Validation

```sh
numpydoc lint $(find lang/python/src/koopa -name '*.py')
```

NumPy-style docstrings; see `[tool.numpydoc_validation]` in `pyproject.toml`
for the enabled checks.

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

- `etc/koopa/app.json`: central app registry (version, default, installer).
  Edit freely; run `koopa develop format-app-json` after changes; bump `revision`.
- Dotfiles: chezmoi-managed, source at `opt/dotfiles/chezmoi/`. Always edit the
  source file, never the deployed copy under `~`.
- Platform: macOS arm64 and Linux x86_64/arm64. Intel Mac not supported.
- Line length: 100 chars. Python 3.14+. NumPy-style docstrings.

## Key Conventions

- Never commit or push; leave version control to the user.
- Never install packages or add dependencies without being asked.
- Never suppress linting errors with `# noqa`; fix the underlying code.
- Use `subprocess.run(..., check=True)`, never `check=False`.
- XDG base dirs: use `from koopa.xdg import xdg_config_home, xdg_data_home`.
  Never hardcode `~/.config` or `~/.local/share`.
- Plans and TODOs go in `todo.org` (Org mode) at the repo root, not
  `.claude/todo.md`.
- After a correction, route the lesson to its home (skill, path-scoped rule,
  or slim core) per `.agents/rules/koopa-lessons.md`. Don't accumulate
  everything in one file.

## Agent configuration

Skills and rules are authored once, under one shared tree, so every agentic
tool reads the same content instead of a per-vendor copy:

| Path | Owner | Read natively by |
|---|---|---|
| `AGENTS.md` | authored | Copilot, Codex, Gemini (via `GEMINI.md`), Claude (via `CLAUDE.md`) |
| `.agents/skills/koopa-*/SKILL.md` | authored | Codex, Gemini, Copilot CLI |
| `.agents/rules/koopa-*.md` | authored, `paths:` frontmatter | source for the generated adapter below |
| `.claude/skills`, `.claude/rules` | symlinks to the two trees above | Claude Code, VS Code Copilot |
| `.github/instructions/koopa-*.instructions.md` | generated, `applyTo:` | Copilot CLI, VS Code Copilot |
| `plugins/koopa/plugin.json` | authored, Agent Plugins 1.0 | Copilot, Codex |
| `plugins/koopa/.claude-plugin/plugin.json`, `plugins/koopa/gemini-extension.json` | generated | Claude, Gemini |

Treat every generated file as owned by `koopa develop generate-agent-config`;
edit its canonical input and regenerate, never the generated file itself.
`koopa develop check` runs it in `--check` mode as the gate's first phase.

Codex and Gemini CLI have no path-scoped instruction mechanism. Before
editing, check `.agents/rules/`: each rule's `paths:` frontmatter names the
files it governs, and `koopa-lessons.md` (no `paths:`) always applies.

Subagents: none exist yet. When the first one is added, follow the same
pattern: `.agents/agents/<name>.md` canonical, a `.claude/agents` directory
symlink to it, and a generated `.github/agents/<name>.agent.md` adapter.

## Global Behavior Rules

See `~/.gemini/GEMINI.md` (Antigravity CLI / `agy`) or `~/.codex/AGENTS.md`
(Codex) for global interaction style, thinking rules, coding standards, and
security rules that apply across all projects.
