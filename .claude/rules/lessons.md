# Lessons (koopa core)

> Cross-project patterns live in `~/.claude/rules/lessons.md` (user-curated).
> Per-project lessons that grow beyond a one-liner belong in a skill or path-scoped
> rule below — don't accumulate prose here.

## Conventions

- **Plan filenames**: use the system-generated filename as-is; never add a
  `YYYY-MM-DD-` prefix. VS Code's plan review UI requires the exact system filename.
- **Plans / TODOs**: write to `todo.org` (Org mode) at the repo root —
  NOT `.claude/todo.md`.
- **Never run `find /` or any filesystem-root search.** Scope every `find`/search
  to a known root: the repo, `~/git`, an app prefix, or a specific cache dir (e.g.
  `~/.cache/uv/...`). A root-wide search is slow, noisy, and reaches unrelated
  trees the task never asked about.

## Skills (load body on invocation)

| Skill | Covers |
|---|---|
| `koopa-atuin` | bash hook architecture (bash-preexec requirement), activation files, installer patterns, DB reset + re-import, config.toml inventory |
| `koopa-app-registry` | `koopa install` syntax, atuin import, successor/default, completions, zsh version format, tool-inclusion scope, installer `main()` contract (only name/version/prefix/passthrough_args passed), `import_app_json()` pattern for extra fields, `extra_fields_fn` in `_AppCheckSpec` for auto-update of non-version metadata, GNU/Savannah host unreliability + mirror-relative-path derivation (`_gnu_mirrors`/`_savannah_mirrors` in `download.py`), dead-host circuit breaker (`_fetch_first_reachable` in `version_check.py`), `koopa develop mirror-src` verification |
| `koopa-release` | CHANGELOG format, bumpver contract (tag=false/push=false), pre-release gate (pytest+ruff+pyright), what's user-owned (tag/push/merge) |
| `koopa-python-release` | Acid Genomics Python package release — python.acidgenomics.com PEP 503 index at `/simple/`, same-domain docs at `/<name>/`, generated landing page, `koopa app python publish/publish-docs/sync-docs-theme/reindex`, quality gate config (ty/pyright exclude tests, pythonpath src), CHANGELOG format, verification smoke-test, `uv run` venv-shebang gotcha, Sphinx docs-build RST/numpydoc gotchas, shared acidgenomics Sphinx theme vendored from koopa (basic-theme based, no pydata-sphinx-theme). See `koopa-r-release` for the R analog. |
| `koopa-aws-env` | `.env` design — `load_dotenv()`/`aws_account_id()`/`koopa_s3_bucket()` helpers in `aws.py`, required vars (`AWS_ACCOUNT_ID`, `AWS_CLOUDFRONT_DISTRIBUTION_ID_*`), bucket naming convention, lazy-eval rule (never module scope), how to add new secrets, history-scrub provenance |
| `koopa-r-release` | Acid Genomics R package release — cloud-native S3 + CloudFront, profile `acidgenomics`, CF distribution ID in `.env` (IDs/bucket via `koopa_s3_bucket('r')` in `cran.py`), `koopa app r publish/publish-from-github/reindex/archive/publish-docs`, sonoma-arm64 only active binaries, dep auto-install for binary builds, `_SKELETON_BINARY_PREFIXES` for big-sur-arm64 warning suppression, 16 packages still need Apache-2 relicense, pre-release gate via `AcidDevtools::check()`, impl in `cran.py`, pkgdown NEWS.md/reference-index/one_page silent-failure traps |
| `acid-r-package` | Acid Genomics R package dev conventions — per-project `air.toml` required (no global config), `~/.lintr` global only (no per-project files), `object_usage_linter = NULL` for S4, roxygen2 8.x single-line `@importFrom` split pattern (never `# nolint` on `#'` lines), `keyword_quote_linter` unquote list names, `leftJoin` type coercion before join, `future::plan("multicore")` not `"multiprocess"`, `AcidDevtools::check()` gate |
| `bioconda` | bioconda-recipes maintenance — global r-base pin location, dependency solve failures (migration lag diagnosis + build-number bump fix), Acid R dep order (tier 1–4), `license_file` LICENSE→LICENSE.md mismatch (sign of Apache-2 relicense), GitHub Contents API for PRs (avoids slow `git push` on 700 MB repo), autobump PR patterns, verification commands |
| `koopa-shell-internals` | git recovery in `update_koopa()`, lazy-load vs eager init, activation fork budget + verify commands, cache-functions-before-reload ordering constraint, non-interactive activation is opt-in (`KOOPA_AUTO_ACTIVATE=1`; rc-file-read matrix per invocation, `KOOPA_FORCE` side effects, side-effect-gating across all 3 shell families, bash-3.2 header routing, re-activation short-circuit, why default-on was reverted) |
| `koopa-update` | `koopa update` full flow (pull→apps→system-apps), admin-gated automatic system updates (`is_admin()` macOS admin-group membership vs `has_sudo()` probe), Homebrew brew-on-PATH trigger, system-R string-inequality version check + "out of date" warning, update-system platform matrix |
| `nushell` | parse-time `use`/`source` constraints, `nu -c` doesn't load config, env.nu→config.nu load order, starship+zoxide cache bootstrap, deprecated syntax (0.78→0.113), `ν` prompt glyph |
| `koopa-color-mode` | SSH OSC 2031, env- vs file-driven timing, VS Code OSC 11 leak, targeted chezmoi apply, render-from-OS rule, never re-verify from agent session, abrupt-SSH-death terminal wedge (mouse+mode-2031 leak) + `koopa run reset-terminal` recovery, Linux gdbus `uint32` substring-collision stuck-light bug, POSIX `read` clobbering a successfully-read cache value, dead in-tmux re-derive in `activate-color-mode.sh`, two-repo fix needs both halves pushed + pin bumped, on-disk-only target check wedges the whole `chezmoi apply` when one discovered target is unmanaged (filter against `chezmoi managed`, never disk existence), main-tree-only apply silently freezing a work-tree-owned target (e.g. Claude Code's settings.json) until a full dotfiles run, and a code fix to color_mode.py not taking effect until the applied-marker is cleared |
| `koopa-theming` | JetBrains scheme delivery + synthesis, macOS sandbox/BBEdit, atuin `[theme]` format, mcfly ANSI palette, Dracula Pro runtime architecture, fish color pipeline (`fish_frozen_theme.fish` override, `_FISH_COLOR_ROLES`, live sync hook, alucard ANSI-8 quirk, proprietary hex audit), vim airline explicit theme read + nvim lualine palette-reading theme function (why `theme = 'auto'` silently produces wrong colors) |
| `koopa-chezmoi-dotfiles` | source path, always-edit-source-first, templates-before-generators, XDG in templates, re-run command |
| `koopa-dotfiles` | opt/dotfiles standalone clone, detached-HEAD-before-commit, license metadata, SHA-pin rollout (app.json `version` field) + known "fix looks unshipped" failure mode |
| `koopa-google-ai-cli` | Antigravity CLI (`agy`) installer — GCS versioned-URL pinning, build_id+SHA512 stored in app.json (auto-updated via `extra_fields_fn`), self-update gate, `~/.gemini/` config layout, gemini-cli successor relationship |
| `koopa-completion` | completion generator architecture, bash lazy-load, zsh compdump freshness, flag-gate bug pattern (bare TAB on leaf commands), `generate-completion` regen workflow |
| `git` | git 2.55 features — `git history` (fixup/reword/split), `format-rev` (EXPERIMENTAL), `url-parse`, `checkout -m` autostash, `--graph-lane-limit`, `--max-count-oldest`, push to remote groups, Linux fsmonitor |
| `koopa-git` | koopa develop→main PR pattern, `-X ours` conflict resolution, tag management, rebase-abort recovery |
| `git-history-surgery` | git filter-repo identity rewrites, commit-tree replay for dedup (user-global skill) |
| `elvish` | `eval` namespace isolation, closure/fn capture order, `use` compile-time lexical scoping, `edit:` interactive-only, `path:` 0.21.0 API, `brew shellenv` workaround, `(src)` under eval, koopa activation architecture |
| `powershell` | activation architecture, starship mtime-guarded cache + header.ps1 ordering constraint, color-mode sync hook (file re-render trigger, marker+sentinel guard, `Start-Process -NoNewWindow` idiom), `_koopa_is_light_mode` per-platform detection, `sys.platform == "win32"` guard for `winreg` |
| `koopa-rust` | Rust/cargo conventions for koopa installers — hermetic `CARGO_HOME` (always `tempfile.mkdtemp(prefix="koopa-cargo-")`), `"rust"` in `build_dependencies`, `NO_RUST` opt-out policy, offline crate check |
| `koopa-vscode` | VS Code terminal font + Nerd Font glyph debugging (CoreText family names, `mdls` lookup, App Support symlink bridge, write-race prevention via `autoDetectColorScheme`), Quarto VS Code plugin + LuaLS `.luarc.json` — portable path pattern, remove `Generator` key, LuaLS placeholder support |
| `license` | Apache-2.0 LICENSE file conventions — canonical sources per repo type (Python/koopa/dotfiles: `gh api /licenses/apache-2.0`; R packages: usethis template), how GitHub licensee detection works, corruption history, badge wiring |
| `koopa-distribution` | install/distribution mechanics outside `curl \| sh` — pinned (non-git) tree already supports app management + update detection via `_require_git_managed_install()`/`update_koopa()`, why conda-forge/package-manager distribution doesn't fit (prefix self-management conflict, seed-package update-divergence bug), `git archive` reads `.gitattributes` from the committed tree (`--worktree-attributes` for uncommitted testing), `KOOPA_FORCE=1` needed to test activation non-interactively, bootstrap.sh has no vendor-mirror awareness |

## Path-scoped rules (load when matching file is opened)

| Rule file | Paths | Covers |
|---|---|---|
| `rules/python.md` | `**/*.py`, `**/pyproject.toml` | `check=True`, `has_sudo`, dev-tools-standalone, XDG helpers, CLI completions, color-mode apply paths |
| `rules/app-json.md` | `**/app.json` | `format-app-json`, revision bump, completions, successor invariant, version URL verification |
| `rules/zsh.md` | `lang/zsh/**` | ShellCheck doesn't support zsh |
| `rules/fish.md` | `**/*.fish` | `$VAR` not `${VAR}`; `set -g` vs `-gx` vs `-U` for color vars; `fish_variables` clobber trap; `fish_frozen_theme.fish`; conf.d load order; `fish_color_*` hex format; `set -S` diagnostic |
| `rules/bash.md` | `lang/bash/**`, `lang/sh/**`, `**/*.sh`, `.claude/skills/**/*.md` | `${VAR}` only when adjacent text follows (path suffix, concatenation); bare `$VAR` when standalone; fish excepted |
| `rules/theme-colors.md` | `**/*.tmpl`, `**/themes/**`, etc. | Never hardcode Dracula Pro hex in tracked files |
