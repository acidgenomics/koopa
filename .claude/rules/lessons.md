# Lessons

## Git Recovery: Handle Both MERGING and Rebasing States

When recovering from a failed `git pull` in `update_koopa()`, handle both interrupted merge state (`.git/MERGE_HEAD`) and interrupted rebase state (`.git/rebase-merge` or `.git/rebase-apply`). `git pull` may use either merge or rebase strategy depending on config and git version.

The fix has two layers:
1. **Proactive**: abort any stuck merge/rebase before attempting to pull (clears MERGING state so the pull can even run).
2. **Reactive**: if the pull still fails (diverged history), fetch + hard reset to `origin/<branch>`.

`git_merge_abort()` and `git_rebase_abort()` are both no-ops when no such operation is in progress, so calling them unconditionally before every pull is safe.

## Shell Plugin Activation: Prefer Lazy Loading Over Eager Init

When evaluating whether to cache or optimize a shell plugin's init output, first check whether the plugin is already lazy-loaded (i.e., the real init runs on first use via an alias or wrapper, not at shell startup). Caching the init output of a lazy-loaded plugin adds complexity with no warm-startup benefit — the fork doesn't happen at startup regardless.

**Known lazy-loaded plugins in koopa:**
- `zoxide` — activated via the `z` alias (`_koopa_activate_zoxide; __zoxide_z`)
- `conda` — activated via the `conda` alias (`_koopa_activate_conda; conda`)

For plugins that ARE eagerly activated at startup (direnv, starship, mcfly, pyenv, rbenv), mtime-based caching of init output in `~/.cache/koopa/shell-init/` is appropriate.

**Rule:** Before proposing init-output caching for a plugin, check whether it is already lazy-loaded. If it is, focus on ensuring the lazy wrapper is fork-free, not on caching the eager path.

## Shell Activation Performance: Keep Forks Out of the Activation Path

Shell activation speed matters. Every `$(...)` subshell in the activation path
costs ~3-5ms on macOS. The current thresholds are bash ≤43 forks, zsh ≤39 forks
across the activate/, export/, and macos/ function directories plus the header.

**Rules:**
- Never use `$(_koopa_bin_prefix)` in activation-path functions — use `${KOOPA_PREFIX:?}/bin` directly.
- Never use `$(_koopa_is_macos)` or `$(_koopa_is_linux)` in bash/zsh — use `[[ "$OSTYPE" == darwin* ]]`.
- Never use `$(_koopa_xdg_config_home)` or `$(_koopa_xdg_data_home)` after `_koopa_activate_xdg` has run — use `${XDG_CONFIG_HOME:?}` / `${XDG_DATA_HOME:?}` directly.
- Never use `$(_koopa_shell_name)` in activation functions — use `${KOOPA_SHELL##*/}`.
- Never use `$(_koopa_boolean_nounset)` / `nounset="$(...)"` — use `[[ -o nounset ]]` inline.
- Never use `$(_koopa_add_to_path_string_start)` — path prepend/dedup is inlined fork-free in `_koopa_add_to_path_start`.

**To verify before merging shell changes:**
```
koopa develop activation-fork-audit --verbose
koopa develop activation-speed-test
koopa develop pytest lang/python/tests/test_cli_develop.py::test_activation_fork_audit_passes
```

## Plan Files: System-Generated Names Must Be Used As-Is

When the system specifies a plan filename (in the plan mode system message), use that exact path — do NOT rename it with a `YYYY-MM-DD-` prefix. VS Code's plan review UI looks for the exact filename the system specified; renaming breaks the UI.

The `YYYY-MM-DD-` date prefix convention applies only to manually created plan/reference docs, not system-assigned plan filenames.

## Use `has_sudo` for Sudo Checks — Don't Add New Sudo Functions

`koopa.system.has_sudo()` is the single function for checking whether
sudo is currently usable without a password prompt. Do not create additional helpers
(e.g., `_has_sudo`, `can_sudo`, `check_sudo`) for this purpose — they duplicate it.
Always import and reuse `has_sudo` from `koopa.system`.

## app.json Edits Require Formatting and a Revision Bump

After modifying `etc/koopa/app.json`, always run:

```
koopa develop format-app-json
```

This keeps formatting consistent and all keys sorted correctly. Also increment
the `revision` field for the edited app entry (add `"revision": 1` if absent)
to signal that installed instances need to be re-linked or reinstalled.

## Chezmoi Templates Run Before Post-Install Generators

When a chezmoi template needs to detect something that an install script
generates *after* `chezmoi apply` (e.g., a file written by a post-chezmoi
function), `stat` on the generated output will always miss — chezmoi runs
first. Instead, detect the *source* that triggers generation (e.g., the
upstream `.tmTheme` file that causes `.rstheme` to be generated) rather than
the generated artifact itself.

## CLI Changes Require Regenerating Completions

When renaming, adding, or removing CLI commands in koopa, always run
`koopa develop generate-completion` afterward. The shell autocomplete definitions
are generated, not hand-maintained, so they go stale if not regenerated. This
caused `koopa app brew upgrade-brews` to appear in completions even though the
command was renamed to `koopa app brew upgrade`.

## Correct Command to Re-run Dotfiles Installer

The command to re-run the dotfiles install script is:

```
koopa configure user dotfiles
```

NOT `koopa configure-dotfiles` (that command does not exist).

## Dev Tools Are Standalone Apps — Never Add to .venv

Tools like `ruff`, `ty`, `pyright`, and `pytest` are installed as standalone
koopa apps (under `app/` or `opt/`), NOT as dependencies in the project `.venv`.
Never suggest adding them to `[project.optional-dependencies]` or installing
them via `uv pip install` into the venv. They run from PATH as independent
binaries with their own Python environments.

## macOS Sandboxed App Containers Cannot Be Written From External Processes

macOS TCC (Transparency, Consent, and Control) blocks ALL external process I/O
to sandboxed app containers on modern macOS — including `defaults write`,
`PlistBuddy`, `plistlib` file writes, and direct file writes into
`~/Library/Application Support/<App>/`. This is a kernel-level restriction, not
a Python or API issue.

**BBEdit 16 is fully sandboxed.** `~/Library/Application Support/BBEdit/Color Schemes/`
is inside the container and cannot be written to from install scripts. Do not
check `os.path.isdir(bbedit_schemes)` and write there — it will silently fail.

**Pattern for sandboxed app theme/config files:**
- Write generated files to a non-sandboxed source directory (e.g.,
  `~/.local/share/dracula-pro/themes/bbedit/`)
- Print a notice telling the user to open/import the files from within the app

```python
# Write to non-sandboxed source dir
os.makedirs(out_dir, exist_ok=True)
with open(os.path.join(out_dir, "MyTheme.bbColorScheme"), "w") as fh:
    fh.write(scheme_content)

# Tell the user — do NOT attempt writes into ~/Library/Application Support/BBEdit/
print(f"BBEdit: open .bbColorScheme files from {out_dir} in BBEdit to install.")
```

## Dotfiles Are Managed by Chezmoi — Always Edit the Source First

Home-directory dotfiles (e.g., `~/.config/nvim/`, `~/.claude/settings.json`,
`~/.bashrc`) are managed by chezmoi. The source of truth is:

```
~/.local/share/koopa/opt/dotfiles/chezmoi/
```

**Always edit the chezmoi source file first.** Never edit only the deployed
copy — it will be overwritten on the next `chezmoi apply`.

When a task involves modifying a deployed dotfile (e.g.,
`~/.config/nvim/lua/plugins/treesitter.lua`), immediately locate and edit the
corresponding source file (e.g.,
`~/.local/share/koopa/opt/dotfiles/chezmoi/dot_config/nvim/lua/plugins/treesitter.lua`)
in the same operation. Do not treat the deployed copy and the source as two
separate steps — edit the source, and let chezmoi deploy it.

## ShellCheck Does Not Support Zsh — Never Suggest It for `lang/zsh/`

ShellCheck cannot analyze zsh. All ShellCheck warnings from files under
`lang/zsh/` are false positives — they say "zsh not supported" and nothing
more. `koopa develop shellcheck` already excludes zsh files intentionally.

**Rules:**
- Never suggest running ShellCheck on files under `lang/zsh/`.
- Never suggest adding `# shellcheck` directives to zsh files to suppress
  "SC" warnings — the warnings are meaningless because the tool doesn't parse
  zsh.
- Files under `lang/zsh/functions/` use `#!/usr/bin/env zsh` shebangs with a
  `.sh` extension — this is intentional. Do not suggest renaming to `.zsh`
  unless the user asks.
- The only shell linting for zsh files is the custom regex-based illegal-string
  checks inside `_handle_shellcheck()` in `cli_develop.py`.

## Fish Shell Variable Style: Never Use `${VAR}` — Use `$VAR`

`${VAR}` is a bash-ism. Fish's parser already unambiguously delimits variable
names without braces, so curly braces add noise with no benefit. Always use
plain `$VAR` in fish scripts:

```fish
# Correct
set -l starship "$KOOPA_PREFIX/bin/starship"
test -x "$KOOPA_PREFIX/bin/fzf"
set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/starship-fish.fish"

# Wrong (bash-ism — do not use)
set -l starship "${KOOPA_PREFIX}/bin/starship"
test -x "${KOOPA_PREFIX}/bin/fzf"
```

This applies to all environment variables referenced in activation functions
(`KOOPA_PREFIX`, `XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `HOME`, etc.).

## subprocess.run: Always Use `check=True` — Never `check=False`

Always pass `check=True` to `subprocess.run`. Fail fast on subprocess errors.
Never suppress failures with `check=False` — that silently swallows errors and
makes debugging harder.

The ruff linter warns `PLW1510` when `check` is omitted. The correct fix is
always `check=True`, not `check=False`.

## New App Entries Require Completion Regeneration

When adding a **new** app to `app.json` (i.e., a brand new entry that didn't
exist before), always run `koopa develop generate-completions` afterward. The
completions are generated from the app registry, so a new app name won't appear
in tab-completion until regenerated.

Toggling `"default": true/false` or updating `"version"`/`"date"` on an
**existing** entry does NOT require regeneration — the app name is already in
the completion lists.

## `~/.local/share/chezmoi` Must Not Exist — Chezmoi Source Is `opt/dotfiles/chezmoi/`

Chezmoi's default source path is `~/.local/share/chezmoi`. In this project, chezmoi is always invoked with an explicit `--source=<opt/dotfiles>/chezmoi` flag (see the `main()` function in `opt/dotfiles/install`). The `opt/dotfiles/` directory (the full dotfiles repo clone) is NOT the chezmoi source root — only its `chezmoi/` subdirectory is.

**`~/.local/share/chezmoi` must not exist.** If it does, it was created accidentally (e.g., a symlink to `opt/dotfiles`). A bare `chezmoi apply` without `--source` would then deploy `dot_*` files into `~/chezmoi/` instead of `~/`, which is wrong and confusing.

**Rules:**
- Never create `~/.local/share/chezmoi` or any symlink pointing there.
- Never run `chezmoi apply` without `--source=...` pointing at `opt/dotfiles/chezmoi/`.
- If `~/.local/share/chezmoi` exists, warn the user and remove it (after confirming it's just a stale symlink, not actual user data).
- The correct chezmoi source path is: `~/.local/share/koopa/opt/dotfiles/chezmoi/`

## Atuin Theme Files Require a `[theme]` Section with `name`

Atuin custom theme files (`~/.config/atuin/themes/NAME.toml`) must contain a `[theme]` section with a `name` field in addition to `[colors]`. Without it, the theme silently fails to load and atuin renders in monochrome black and white using built-in defaults.

Correct format:

```toml
[theme]
name = "my-theme-name"

[colors]
Important = "#383a42"
...
```

The `name` must match the filename stem (e.g., `dracula-pro-alucard.toml` → `name = "dracula-pro-alucard"`).

## McFly Colors Through SSH+tmux: Named ANSI Colors Are Palette-Dependent

McFly's config.toml only supports the 16 named ANSI colors (e.g., `"grey"`, `"black"`, `"blue"`). It does **not** support hex values — they silently fall back to white.

The problem: named ANSI colors render differently depending on the **local terminal emulator's** palette, not anything on the remote. The ANSI palette passes through SSH unchanged, but tmux intercepts and re-renders colors using its internal state — so the effective rendering depends on which terminal is used to attach to the tmux session.

**Ghostty + Dracula Pro Alucard ANSI palette** (the relevant mapping):
- ANSI 0 (`black`) = `#fafafa` — near-white, **washed out as foreground**
- ANSI 7 (`grey`) = `#383a42` — near-black, **legible as foreground**
- ANSI 8 (`dark_grey`) = `#FFFFFF` — pure white, **washed out as foreground**
- ANSI 15 (`white`) = `#383a42` — very dark, **legible as foreground**
- ANSI 4 (`dark_blue`) = `#a626a4` (purple)
- ANSI 12 (`blue`) = `#7c6f9e` (lighter purple)

VS Code and macOS Terminal.app use different palettes where ANSI 0 is dark, so the same config appears fine there but broken in Ghostty.

**The Alacritty issue** (`https://github.com/cantino/mcfly/issues/316`) is the same class of problem — terminal emulators with non-standard ANSI palette mappings break mcfly's named color assumptions.

**Rules for mcfly color config:**
- For light mode with Dracula Pro Alucard (Ghostty): `results_fg = "grey"` (ANSI 7 = dark) works; `results_fg = "black"` or `"dark_grey"` do NOT.
- Always test mcfly colors from the specific terminal emulator that will be used — VS Code and Ghostty can give opposite results for the same config.
- The chezmoi template `config.toml.tmpl` conditions on `stat ~/.local/share/dracula-pro` to detect whether the Alucard palette is in play.

## Atuin Import: Use Explicit Shell Name, Never `auto` on macOS

`atuin import auto` detects the shell from `$SHELL`, which on macOS is `/bin/zsh` (the system default) regardless of what shell is actually running. If you're running bash on macOS, `atuin import auto` will incorrectly import from zsh history.

Always import with the explicit shell name:

```bash
atuin import bash   # when running bash
atuin import zsh    # when running zsh
```

Never use `atuin import auto` on macOS.

## koopa Install Command Is `koopa install <app>` Not `koopa app install <app>`

The correct command to install a koopa app is:

```
koopa install atuin
```

NOT `koopa app install atuin`. The `app` subcommand does not exist for installation.

## Plans and TODOs Use `todo.org` (Org Mode)

When preparing future plans or TODO list items for this project, write them to
`todo.org` at the project root. This file is formatted as an Org mode document.
Do not use `.claude/todo.md` or other formats for project task tracking.

## Apps with `successor` Must Have `default: false`

If an app entry in `app.json` has a `"successor"` field defined, it must also
have `"default": false`. It makes no sense to install an app by default when a
known better alternative exists. Treat this as an invariant — enforce it in any
code that validates or processes the `successor` field.

## AI Tool Scope: Major Vendors Only

When evaluating AI agentic coding tools for inclusion in koopa, only include tools from major vendors: Anthropic, Google, OpenAI, Microsoft (GitHub), and Amazon. Do not suggest OSS community tools (aider, goose, OpenHands, etc.) regardless of popularity — the scope is intentionally narrow to vendor-backed products.

## `etc/koopa/app.json` Is a Freely Editable File

`etc/koopa/app.json` is the central app registry and is edited frequently (adding
tools, bumping versions, toggling defaults). Never prompt for confirmation when
editing this file — treat it like any other routine edit. The `Edit` permission
already covers it; if plan mode is blocking edits, exit plan mode first rather
than asking for per-edit approval.
