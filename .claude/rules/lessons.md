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
| `koopa-atuin` | bash hook architecture (bash-preexec requirement), activation files, installer patterns, DB reset + re-import, config.toml inventory |
| `koopa-app-registry` | `koopa install` syntax, atuin import, successor/default, completions, zsh version format, tool-inclusion scope, installer `main()` contract (only name/version/prefix/passthrough_args passed), `import_app_json()` pattern for extra fields, `extra_fields_fn` in `_AppCheckSpec` for auto-update of non-version metadata |
| `koopa-release` | CHANGELOG format, bumpver contract (tag=false/push=false), pre-release gate (pytest+ruff+pyright), what's user-owned (tag/push/merge) |
| `koopa-python-release` | Acid Genomics Python package release — python.acidgenomics.com hosting (S3+CloudFront PEP 503 root-URL index), `koopa app python publish`, quality gate config (ty/pyright exclude tests, pythonpath src), CHANGELOG format, verification smoke-test |
| `koopa-shell-internals` | git recovery in `update_koopa()`, lazy-load vs eager init, activation fork budget + verify commands |
| `nushell` | parse-time `use`/`source` constraints, `nu -c` doesn't load config, env.nu→config.nu load order, starship+zoxide cache bootstrap, deprecated syntax (0.78→0.113), `ν` prompt glyph |
| `koopa-color-mode` | SSH OSC 2031, env- vs file-driven timing, VS Code OSC 11 leak, targeted chezmoi apply, render-from-OS rule, never re-verify from agent session |
| `koopa-theming` | JetBrains scheme delivery + synthesis, macOS sandbox/BBEdit, atuin `[theme]` format, mcfly ANSI palette, Dracula Pro runtime architecture, fish color pipeline (`fish_frozen_theme.fish` override, `_FISH_COLOR_ROLES`, live sync hook, alucard ANSI-8 quirk, proprietary hex audit) |
| `koopa-chezmoi-dotfiles` | source path, always-edit-source-first, templates-before-generators, XDG in templates, re-run command |
| `koopa-dotfiles` | opt/dotfiles standalone clone, detached-HEAD-before-commit, license metadata |
| `koopa-google-ai-cli` | Antigravity CLI (`agy`) installer — GCS versioned-URL pinning, build_id+SHA512 stored in app.json (auto-updated via `extra_fields_fn`), self-update gate, `~/.gemini/` config layout, gemini-cli successor relationship |
| `koopa-completion` | completion generator architecture, bash lazy-load, zsh compdump freshness, flag-gate bug pattern (bare TAB on leaf commands), `generate-completion` regen workflow |
| `git-history-surgery` | git filter-repo identity rewrites, commit-tree replay for dedup (user-global skill) |
| `elvish` | `eval` namespace isolation, closure/fn capture order, `use` compile-time lexical scoping, `edit:` interactive-only, `path:` 0.21.0 API, `brew shellenv` workaround, `(src)` under eval, koopa activation architecture |
| `powershell` | activation architecture, starship mtime-guarded cache + header.ps1 ordering constraint, color-mode sync hook (file re-render trigger, marker+sentinel guard, `Start-Process -NoNewWindow` idiom), `_koopa_is_light_mode` per-platform detection, `sys.platform == "win32"` guard for `winreg` |

## Path-scoped rules (load when matching file is opened)

| Rule file | Paths | Covers |
|---|---|---|
| `rules/python.md` | `**/*.py`, `**/pyproject.toml` | `check=True`, `has_sudo`, dev-tools-standalone, XDG helpers, CLI completions, color-mode apply paths |
| `rules/app-json.md` | `**/app.json` | `format-app-json`, revision bump, completions, successor invariant, version URL verification |
| `rules/zsh.md` | `lang/zsh/**` | ShellCheck doesn't support zsh |
| `rules/fish.md` | `**/*.fish` | `$VAR` not `${VAR}`; `set -g` vs `-gx` vs `-U` for color vars; `fish_variables` clobber trap; `fish_frozen_theme.fish`; conf.d load order; `fish_color_*` hex format; `set -S` diagnostic |
| `rules/theme-colors.md` | `**/*.tmpl`, `**/themes/**`, etc. | Never hardcode Dracula Pro hex in tracked files |
