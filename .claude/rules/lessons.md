# Lessons

## Do Not Hardcode Proprietary Theme Colors in Tracked Files

Proprietary paid-theme hex values (Dracula Pro, Dracula Pro Alucard, etc.) must not
appear as literals in any tracked file. Always derive them at runtime from the locally
installed source at `~/.local/share/dracula-pro/`.

**Rule:** before writing any hex color into a tracked file, verify it does not appear
in the local proprietary palette. If it does, the code must read it at runtime instead.

Free Dracula OSS colors (`#282a36`, `#6272a4`, `#50fa7b`, `#f1fa8c`, `#ff79c6`,
`#bd93f9`, `#8be9fd`, `#ffb86c`, `#ff5555`) are allowed as literals. Generic neutrals
(`#ffffff`, `#000000`, `#fafafa`, plain greys) are fine. Everything else in a
Dracula Pro theme context must be runtime-derived.

When working on any theme-synthesis task:
- Never copy a hex out of a vendor palette file and paste it into a tracked script.
- Never quote proprietary hex values in documentation or lessons files.
- Any doubt → check `grep -iE '<hex>' ~/.local/share/dracula-pro/themes/ghostty/pro`.

## IntelliJ config-dir `colors/` Shadows Plugin-Bundled Schemes of the Same Name

IntelliJ Platform (PyCharm, IntelliJ IDEA, etc.) gives editor scheme files in
`<config>/colors/*.xml` **priority over plugin-bundled schemes of the same name**.
If an old installer wrote a scheme directly to that directory, it silently wins over
the correct plugin-packaged scheme — even if the plugin is loaded and the jar
contains the right colors.

**Symptoms:** the theme is confirmed selected, the plugin jar contains correct light
colors (verified statically), but the editor still renders dark.

**Fix pattern:** when switching from a config-dir scheme delivery to a plugin-bundled
one, always add cleanup in the installer loop to `os.remove()` the stale config-dir
files:

```python
for stale in (
    os.path.join(ide_dir, "colors", "SchemeName.xml"),
    os.path.join(ide_dir, "themes", "SchemeName.theme.json"),
):
    if os.path.isfile(stale):
        os.remove(stale)
```

Run this before installing/updating the plugin so the correct version wins on the
very next launch.

## JetBrains Editor Scheme Synthesis: Derive the Substitution Map at Runtime

When synthesizing a light editor scheme from a dark one by hex substitution, **never
hardcode any proprietary palette values as literals** — not as map keys and not as
map values. Proprietary paid-theme colors (Dracula Pro, Dracula Pro Alucard, etc.) in
a tracked file is an IP violation and has caused public git-history leaks requiring
`filter-repo` scrubs.

**Correct approach:** build the substitution map entirely at runtime:
- Keys come from `_parse_ghostty_palette(dp_dir, "<dark-variant>")` — parsed from the
  local vendor source at `~/.local/share/<theme>/themes/ghostty/<variant>`.
- Values come from `_parse_ghostty_palette(dp_dir, "<light-variant>")`, aligned by
  ANSI index. Non-ANSI roles (orange, etc.) come from the Fleet experimental palette
  JSON at `~/.local/share/<theme>/themes/jetbrains/experimental/fleet/`.
- Tokens in the XML with no named-palette equivalent are lightened algorithmically
  (luminance-flip via `colorsys`). No literals needed.

**Verification (add as a permanent in-function assert):**
```python
survivors = {t.lower() for t in re.findall(r'value="([0-9A-Fa-f]{6})"', xml)} & set(named_map)
assert not survivors, f"Dark tokens survived: {sorted(survivors)}"
for m in re.finditer(r'name="[A-Z_]*BACKGROUND[^"]*"\s+value="([0-9A-Fa-f]{6})"', xml):
    assert _relative_luminance("#" + m.group(1)) >= 0.55
```

## `git filter-repo` Is for Identity Fixes; `git commit-tree` Replay Is for De-duplication

`git filter-repo --mailmap` is the preferred tool for **author/email identity
rewrites** (rename an email across all commits). It's fast, safe, and
well-understood. Use it whenever the only problem is wrong names/emails.

However, `git filter-repo` **cannot de-duplicate** history or remove merge
commits — it preserves the existing graph topology. When the history has been
accidentally doubled (e.g., a botched cleanup rewrote commits into clean copies,
then a `git pull` merged the originals back in, leaving every commit present
twice joined by spurious pull-merges), the correct tool is a **`git commit-tree`
replay**:

1. Read all non-merge commits via `git log`.
2. Group by `(tree, author-date, full commit body)` — this key is a perfect
   logical identity across both duplicate lineages.
3. Pick one canonical copy per group (prefer bot-committed copies to preserve
   `GitHub <noreply@github.com>` committer identity; never pick a
   contaminated/wrong-identity copy).
4. Sort canonicals by author-date (verify no ties first — a perfect total order
   makes replay deterministic).
5. Replay linearly via `git commit-tree <tree> -p <prev>` with the correct
   `GIT_AUTHOR_*` / `GIT_COMMITTER_*` env vars.
6. Verify: tree byte-match against old HEAD, expected commit count, zero
   merges, zero contaminated identities, zero logical commits lost.
7. Only then: `git update-ref refs/heads/main <new-tip>` + force-push.

**The critical safety invariant:** before running, confirm **zero orphan
commits** — i.e., every commit with a wrong/contaminated identity has a clean
twin with the same tree. If any orphan exists, dropping the contaminated copy
loses content and the replay is unsafe.

## `git filter-repo` Is the Preferred Tool for Identity-Only History Rewrites

`git filter-repo` (already on PATH at
`/Users/mike/.local/share/koopa/bin/git-filter-repo`) is the standard for
any commit-history rewrite where only **identity metadata** (author name/email,
committer name/email) needs changing. Never use the deprecated `git
filter-branch`. Example:

```sh
# mailmap file:
# Michael Steinbaugh <mike@steinbaugh.com> <wrong@example.com>
git filter-repo --mailmap <mailmap-file> --force
git remote add origin <url>      # filter-repo removes the remote as a safety measure
git push --force --set-upstream origin main
```

## XDG Base Directories: Always Use the Env Var, Never Hardcode the Path

Never hardcode `~/.config`, `~/.local/share`, `~/.cache`, or `~/.local/state`. Always derive them from the XDG env vars with the spec-mandated fallback:

**koopa Python** — use the helpers (already imported in most files):
```python
from koopa.xdg import xdg_config_home, xdg_data_home, xdg_cache_home
xdg_config_home()   # os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
xdg_data_home()     # os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share"))
```
Never inline `os.path.expanduser("~"), ".config"` or `Path.home() / ".local" / "share"` — these ignore a custom `$XDG_*` override.

**chezmoi templates** — there is no native XDG variable; use:
```
{{- $dataHome := env "XDG_DATA_HOME" | default (joinPath .chezmoi.homeDir ".local/share") -}}
{{- $configHome := env "XDG_CONFIG_HOME" | default (joinPath .chezmoi.homeDir ".config") -}}
```
The `.chezmoi.homeDir` inside `default` is the XDG fallback definition — unavoidable and correct. Reference example: `dot_config/rstudio/rstudio-prefs.json.tmpl:23`.

**Standalone scripts** (no koopa import) — inline the same pattern:
```python
xdg_config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
xdg_data_home = os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
```

**Key distinction:** `XDG_DATA_HOME` (single writable user data dir) vs `XDG_DATA_DIRS` (colon-separated read-only system *search* path — e.g. includes `/usr/share` and Ghostty's resources). Never derive a write/install location from `XDG_DATA_DIRS`.

**Must NOT change:** `xdg.py` helper definitions; `koopa_prefix()` and all `<prefix>/share/...` FHS install-tree paths; IDE-fixed dirs (`~/.vscode`, `~/.positron`); macOS-native `~/Library/...`; per-tool non-XDG convention dirs (`~/.aws`, `~/.ssh`, `~/.conda`, `~/go`, `~/.emacs.d`).

## Color Mode: Env-Driven vs File-Driven Consumers — Different Timing Guarantees

koopa's color-mode consumers split into two categories with very different timing
characteristics:

**Env-driven** (always correct immediately after activation):
`FZF_DEFAULT_OPTS`, `DFT_BACKGROUND`, `MCFLY_LIGHT`, `LS_COLORS`/`DIRENV_COLORS`.
These read `$KOOPA_COLOR_MODE` directly in `_koopa_activate_*` functions. Since
`KOOPA_COLOR_MODE` is set synchronously by `_koopa_activate_color_mode` at the
top of the activation sequence, these are always correct in every new shell.

**File-driven** (depend on on-disk chezmoi-rendered files):
`bat` theme (`~/.config/bat/config` `--theme=` line), starship palette
(`~/.config/starship.toml`), delta theme (`~/.config/delta/theme.gitconfig`).
These read files whose content was baked in at the last `chezmoi apply`. If the
apply hasn't happened yet for the current OS mode, the files are stale and the
tool renders the wrong theme — even though `KOOPA_COLOR_MODE` and all env-driven
tools are correct.

**The classic symptom:** correct terminal theme, correct fzf/LS_COLORS colors,
but wrong bat/starship/delta colors after a dark↔light flip. The env is NOT the
bug — the on-disk theme files are stale. Check the mtime of
`~/.config/bat/config`, `~/.config/starship.toml`, `~/.config/delta/theme.gitconfig`
against the flip time (`.GlobalPreferences.plist` mtime on macOS).

**The fix:** when `~/.cache/koopa/color-mode-applied` ≠ current OS mode, run
`koopa configure user color-mode` **synchronously** (foreground) for interactive
shells so the files are current before bat/starship read them. Non-interactive
shells keep the background spawn (scripts must not block on a chezmoi apply).

## Zsh Uses Semantic Versioning — Never Set Version to a Bare Integer

Zsh's release numbering is `5.x.y` (e.g., `5.9.1`). The integer `26` is **not** a valid zsh version — it is the GNU project major release number of the *zsh project itself*, not the tarball version. Setting `"version": "26"` in `app.json` causes URLs like `zsh-26.tar.xz` to 404.

Always verify the tarball URL at `https://www.zsh.org/pub/` before updating the zsh version. The correct format is always `zsh-{major}.{minor}.{patch}.tar.xz`.

The root cause of the bad version in commit `9662caa0efcd` was a version-check fix that blindly wrote the release number rather than verifying against the actual download URL. Before changing any app version in `app.json`, confirm the tarball exists at the resolved `src_url`.

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

**Re-import is required after every regeneration.** Updating `~/.local/share/dracula-pro/themes/bbedit/` does NOT automatically update the copy inside BBEdit's sandbox. The user must double-click the `.bbColorScheme` file in Finder (or File → Open in BBEdit) to trigger the install prompt each time the theme changes. When a color theme fix appears to have no effect in an active BBEdit session, the first thing to check is whether the updated file has been re-imported — not whether the generator or sandboxing is broken.

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
Important = "#HEX_COLOR"
...
```

The `name` must match the filename stem (e.g., `dracula-pro-alucard.toml` → `name = "dracula-pro-alucard"`).

## McFly Colors Through SSH+tmux: Named ANSI Colors Are Palette-Dependent

McFly's config.toml only supports the 16 named ANSI colors (e.g., `"grey"`, `"black"`, `"blue"`). It does **not** support hex values — they silently fall back to white.

The problem: named ANSI colors render differently depending on the **local terminal emulator's** palette, not anything on the remote. The ANSI palette passes through SSH unchanged, but tmux intercepts and re-renders colors using its internal state — so the effective rendering depends on which terminal is used to attach to the tmux session.

**Ghostty + Dracula Pro Alucard ANSI palette** (the relevant mapping):
- ANSI 0 (`black`) = near-white — **washed out as foreground**
- ANSI 7 (`grey`) = near-black — **legible as foreground**
- ANSI 8 (`dark_grey`) = pure white — **washed out as foreground**
- ANSI 15 (`white`) = very dark — **legible as foreground**
- ANSI 4 (`dark_blue`) = purple variant
- ANSI 12 (`blue`) = lighter purple variant

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

## VS Code / Posit Workbench: OSC 11 Queries Leak `^[\` (ST Character)

Posit Workbench runs VS Code in the browser with an xterm.js terminal. Despite
the comment that xterm.js "supports" OSC 11, Posit Workbench's implementation
does **not** properly consume the String Terminator (`ESC \`) in the response.
The `\033\\` at the end of the OSC 11 query leaks as the literal characters
`^[\` in the terminal output.

**Root cause:** `_koopa_terminal_is_light_background` sends `printf '\033]11;?\033\\' > /dev/tty`
to query terminal background color. Posit Workbench xterm.js doesn't consume the
response correctly, so `ESC \` appears literally as `^[\`. This fires at shell
startup AND on every prompt via `PROMPT_COMMAND`.

**Fix:** Guard with `TERM_PROGRAM=vscode` (VS Code sets this in all integrated
terminals, including Posit Workbench). When detected, skip the OSC 11 query and
fall back to the cache file `~/.cache/koopa/color-mode`, same pattern as tmux.

```bash
elif [[ "${TERM_PROGRAM:-}" == 'vscode' ]]
then
    local cache_file="${HOME:?}/.cache/koopa/color-mode"
    [[ -f "$cache_file" ]] && [[ "$(<"$cache_file")" == 'light' ]]
```

Apply in both `is-light-mode.sh` and `terminal-is-light-background.sh` for
defense-in-depth, across all three shell variants (bash, sh, zsh).

After editing any of these files, run `koopa develop cache-functions` to
regenerate the `include/functions.sh` bundle files.

## launchd/systemd Jobs Must Never Re-Bootstrap Their Own Agent

A background sync job that calls the full dotfiles installer will trigger
`_sync_launchd_agent()` → `launchctl bootout <self>` → SIGTERM mid-run. The
process dies before writing any state marker, leaving a permanent wedge: files
rendered to mode X, marker stuck at mode Y, watcher early-exits forever.

**Rule:** color-mode sync jobs (and any background watcher) must do *only* the
targeted work — never invoke `opt/dotfiles/install` or any path that calls
`_sync_launchd_agent`/`_sync_systemd_user_agent`. Use `chezmoi apply <targets>`
directly; leave agent lifecycle to the full `koopa configure user dotfiles`.

## Color-Mode Switch: Apply Only the Color-Mode Templates (Targeted chezmoi apply)

A color-mode flip must re-render **only** the ~32 templates that branch on
`KOOPA_COLOR_MODE`, via `chezmoi apply <target>...` against the main tree.
Never route a theme switch through the heavy installer or the work/private trees.

**Discovery pattern:** walk the main chezmoi source for `*.tmpl` files containing
`KOOPA_COLOR_MODE`; derive target paths using chezmoi naming conventions
(`dot_` → `.`, strip `.tmpl`, strip attribute prefixes); filter to targets that
exist on disk (skips unmanaged/undeployed templates automatically).

Work/private trees contain zero `KOOPA_COLOR_MODE` logic — re-running them on a
color flip adds age/git/network dependency in a background context and churns
`.claude/settings.json`, `.npmrc`, `.aws/config` needlessly.

## Dotfiles Color-Mode: Render from OS, Never from Inherited Env

Any `chezmoi apply` path that branches on `KOOPA_COLOR_MODE` must derive the
value from the OS at apply time — never trust `os.environ` as inherited from the
calling process. Long-running processes (agent sessions, days-old tmux servers,
stale launchd plists) carry the mode from when they started, not the current OS
state, and will silently render the wrong palette across every template.

**The fix:** call `os_appearance_mode()` (from `koopa.system`) and assign it to
`env["KOOPA_COLOR_MODE"]` (or `os.environ["KOOPA_COLOR_MODE"]`) immediately
before every `chezmoi apply` call, in both `configurers/dotfiles.py` and
`opt/dotfiles/install`'s `main()`.

**The proof this matters:** a `koopa configure user dotfiles` run from a Claude
Code session that started in dark mode clobbered the user's files to dark even
though the OS had been switched to light. The session env carried `dark`; the
OS said `light`; the session won — wrongly.

## Dotfiles Color-Mode Switch: Re-Apply All Trees in Order (Never Main-Only)

A color-mode switch must re-apply main → work → private dotfiles, in that order,
every time — not just the main tree. Applying only the main tree can re-assert a
main-tree file over a work override (e.g. npm, pip, claude configs), leaving work
config silently clobbered until the next full `configure user dotfiles`.

**The fix:** `configurers/color_mode.py` (the lightweight watcher path) delegates
to `dotfiles.py`'s `main()` with `KOOPA_DOTFILES_SKIP_PULL=1` rather than running
its own standalone `chezmoi apply`. This ensures both paths share the same ordered
apply logic and can't diverge.

## Never Run `koopa configure user dotfiles` from an Agent Session to Verify

When verifying dotfile rendering from inside a long-running agent session, do NOT
run `koopa configure user dotfiles` — the session's `KOOPA_COLOR_MODE` is frozen
at the value it had when the session started and will render the wrong palette,
clobbering the user's files. The hostile-env bug above was introduced exactly this
way during a "verification" step.

To verify rendering without risk: check the rendered files' content with `grep`
or `cat` — don't trigger a re-render from a stale env.

## Dracula Pro Colors Must NEVER Be Hardcoded in Tracked Dotfiles

Dracula Pro is a proprietary paid theme. Its specific hex color values are derived
from the locally installed Pro source (`~/.local/share/dracula-pro/`) and are NOT
to be committed to the dotfiles repo, even indirectly.

**Rule:** No Dracula Pro or Dracula Pro Alucard hex values may appear in any
chezmoi template or other tracked file in the dotfiles repo.

**Correct architecture:**
1. `opt/dotfiles/install` (install script) reads colors from the local Pro source
   via `_parse_ghostty_palette(dp_dir, variant)`.
2. Install script generates palette files outside the chezmoi tree, e.g.:
   - `~/.config/zsh/dracula-pro-colors.zsh` (already done)
   - `~/.config/fish/dracula-pro-colors.fish` (needs to be done)
   - `~/.config/starship/dracula-pro.toml` (include fragment)
   - etc.
3. Chezmoi templates source/include those generated files at runtime — they
   conditionally include the generated file if it exists, with a fallback to
   free Dracula OSS colors if it doesn't.

**Never do this in a template:**
```toml
# BAD — Pro colors hardcoded in tracked file
purple = "#PROPRIETARY_HEX"
```

**Do this instead:**
```toml
# GOOD — chezmoi template with conditional include
{{- if stat (joinPath .chezmoi.homeDir ".config/starship/dracula-pro.toml") }}
{{- include (joinPath .chezmoi.homeDir ".config/starship/dracula-pro.toml") }}
{{- else }}
purple = "#bd93f9"
{{- end }}
```
