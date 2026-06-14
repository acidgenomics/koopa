# Lessons (koopa core)

> Cross-project patterns live in `~/.claude/rules/lessons.md` (user-curated).
> Per-project lessons that grow beyond a one-liner belong in a skill or path-scoped
> rule below — don't accumulate prose here.

## Conventions

- **Plan filenames**: use the system-generated filename as-is; never add a
  `YYYY-MM-DD-` prefix. VS Code's plan review UI requires the exact system filename.
- **Plans / TODOs**: write to `todo.org` (Org mode) at the repo root —
  NOT `.claude/todo.md`.

## Skills (load body on invocation)

| Skill | Covers |
|---|---|
| `koopa-app-registry` | `koopa install` syntax, atuin import, successor/default, completions, zsh version format, tool-inclusion scope |
| `koopa-shell-internals` | git recovery in `update_koopa()`, lazy-load vs eager init, activation fork budget + verify commands |
| `koopa-color-mode` | SSH OSC 2031, env- vs file-driven timing, VS Code OSC 11 leak, targeted chezmoi apply, render-from-OS rule, never re-verify from agent session |
| `koopa-theming` | JetBrains scheme delivery + synthesis, macOS sandbox/BBEdit, atuin `[theme]` format, mcfly ANSI palette, Dracula Pro runtime architecture, fish color pipeline (`fish_frozen_theme.fish` override, `_FISH_COLOR_ROLES`, live sync hook, alucard ANSI-8 quirk, proprietary hex audit) |
| `koopa-chezmoi-dotfiles` | source path, always-edit-source-first, templates-before-generators, XDG in templates, re-run command |
| `git-history-surgery` | git filter-repo identity rewrites, commit-tree replay for dedup (user-global skill) |
| `elvish` | `eval` namespace isolation, closure/fn capture order, `use` compile-time lexical scoping, `edit:` interactive-only, `path:` 0.21.0 API, `brew shellenv` workaround, `(src)` under eval, koopa activation architecture |

## Path-scoped rules (load when matching file is opened)

| Rule file | Paths | Covers |
|---|---|---|
| `rules/python.md` | `**/*.py`, `**/pyproject.toml` | `check=True`, `has_sudo`, dev-tools-standalone, XDG helpers, CLI completions, color-mode apply paths |
| `rules/app-json.md` | `**/app.json` | `format-app-json`, revision bump, completions, successor invariant, version URL verification |
| `rules/zsh.md` | `lang/zsh/**` | ShellCheck doesn't support zsh |
| `rules/fish.md` | `**/*.fish` | `$VAR` not `${VAR}`; `set -g` vs `-gx` vs `-U` for color vars; `fish_variables` clobber trap; `fish_frozen_theme.fish`; conf.d load order; `fish_color_*` hex format; `set -S` diagnostic |
| `dot_claude/rules/theme-colors.md` | `**/*.tmpl`, `**/themes/**`, etc. | Never hardcode Dracula Pro hex in tracked files |
