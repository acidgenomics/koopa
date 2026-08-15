---
name: koopa-chezmoi-dotfiles
description: >-
  How koopa manages home dotfiles via chezmoi — source-of-truth layout, the
  explicit --source flag, template-vs-generator ordering, XDG path derivation in
  templates, symlink_ source files for App Support bridges, sharing one template
  body across several deployed targets (.chezmoi.sourceFile, .chezmoitemplates
  partials), verifying a config setting name is real before trusting it,
  diagnosing chezmoi status contamination from stale env, and the correct re-run
  command. Use when editing a dotfile, working in opt/dotfiles/chezmoi/, debugging
  a file that reverts on chezmoi apply, wiring a chezmoi template, deduplicating
  near-identical config templates, or bridging XDG paths to macOS
  Library/Application Support.
---

# koopa Chezmoi Dotfiles

## Source of Truth

The chezmoi source root is:
```
~/.local/share/koopa/opt/dotfiles/chezmoi/
```

**`~/.local/share/chezmoi` must not exist.** Chezmoi is always invoked with an
explicit `--source=<opt/dotfiles>/chezmoi` flag. If `~/.local/share/chezmoi` exists,
it was created accidentally — warn and remove it (after confirming it is not user
data). A bare `chezmoi apply` without `--source` would deploy `dot_*` files into
`~/chezmoi/` instead of `~/`, which is wrong.

**Never run `chezmoi apply` without `--source`** pointing at `opt/dotfiles/chezmoi/`.

## Always Edit the Source First

Home-directory dotfiles are managed by chezmoi. The deployed copies under `~/` will
be overwritten on the next `chezmoi apply`.

**Always edit the chezmoi source file.** When a task touches a deployed dotfile
(e.g. `~/.config/nvim/lua/plugins/treesitter.lua`), immediately locate and edit the
corresponding source file (e.g.
`~/.local/share/koopa/opt/dotfiles/chezmoi/dot_config/nvim/lua/plugins/treesitter.lua`).
Do not treat the deployed copy and the source as two separate steps.

After editing, deploy with a targeted apply:
```sh
chezmoi apply \
  --source=~/.local/share/koopa/opt/dotfiles/chezmoi \
  ~/.config/nvim/lua/plugins/treesitter.lua   # whichever file(s) changed
```

**Do NOT run `koopa configure user dotfiles` from inside a long-running agent session**
— the session's `KOOPA_COLOR_MODE` may be stale and will clobber theme files. See
skill `koopa-color-mode`.

## Re-Run Command

To re-run the full dotfiles installer:
```sh
koopa configure user dotfiles
```
NOT `koopa configure-dotfiles` (that command does not exist).

## Templates Run Before Post-Install Generators

Chezmoi templates execute **before** any post-install generator runs. When a template
needs to detect something that a post-chezmoi function generates (e.g. a `.rstheme`
file generated from an upstream `.tmTheme`), `stat` on the generated output will
always miss at template render time.

Instead, detect the **source** that triggers generation (e.g. the upstream `.tmTheme`
file itself) rather than the generated artifact.

## XDG Paths in Chezmoi Templates

chezmoi has no native XDG variables. Use:
```
{{- $dataHome := env "XDG_DATA_HOME" | default (joinPath .chezmoi.homeDir ".local/share") -}}
{{- $configHome := env "XDG_CONFIG_HOME" | default (joinPath .chezmoi.homeDir ".config") -}}
```

The `.chezmoi.homeDir` fallback is the XDG spec definition — unavoidable and correct.

In standalone scripts (no `koopa` import), inline:
```python
xdg_config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
xdg_data_home = os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
```

Never confuse `XDG_DATA_HOME` (single writable user data dir) with `XDG_DATA_DIRS`
(colon-separated read-only system search path). Never derive a write/install location
from `XDG_DATA_DIRS`.

## Removing a File from the Chezmoi Source Leaves an Orphan

Deleting a file from the chezmoi source tree does **not** cause `chezmoi apply` to
remove the deployed copy under `~/`. Chezmoi only manages what it knows about; once a
source file is deleted, chezmoi silently ignores the deployed counterpart — it becomes
an untracked orphan that persists indefinitely.

**The correct fix is `.chezmoiremove`**, not a manual `rm`. Add a `.chezmoiremove` file
in the corresponding source directory listing the entries to purge. Chezmoi will then
remove the deployed targets on the next `chezmoi apply`, and keep removing them on every
subsequent apply — preventing stale copies from reappearing.

Keep a **single `.chezmoiremove` at the chezmoi source root** (`chezmoi/.chezmoiremove`),
with all entries as paths relative to `~`. Never nest per-subdirectory `.chezmoiremove`
files — the root file is the one place to audit all removals:

```
opt/dotfiles/chezmoi/.chezmoiremove
```
```
.claude/rules/theme-colors.md
.claude/skills/koopa-chezmoi-dotfiles
.claude/skills/koopa-color-mode
.claude/skills/koopa-theming
```

On `chezmoi apply --source=~/.local/share/koopa/opt/dotfiles/chezmoi`, the listed
targets are removed from `~`. No manual `rm` needed.

This applies to all chezmoi-managed content: dotfiles, Claude Code skills, rules,
settings — anything under `opt/dotfiles/chezmoi/dot_*/`.

Failing to add a `.chezmoiremove` entry means the orphan remains active (e.g. as a
globally-available Claude skill) even though the source no longer tracks it.

## macOS App Support Bridges: Use symlink_ Source Files

macOS apps like VS Code, Cursor, Positron, Antigravity, nushell, and ruff read
config from `~/Library/Application Support/<App>/` rather than the XDG
`~/.config/<App>/` path that chezmoi manages. Bridge these with chezmoi-native
`symlink_` source files — not imperative Python in `opt/dotfiles/install`.

**Source file layout:**
```
private_Library/
  Application Support/         ← literal space, fine in chezmoi v2
    Code/User/
      symlink_settings.json.tmpl
      symlink_keybindings.json.tmpl
    Cursor/User/
      symlink_settings.json.tmpl
    Positron/User/
      symlink_settings.json.tmpl
    Antigravity/User/
      symlink_settings.json.tmpl
      symlink_keybindings.json.tmpl
    nushell/
      symlink_config.nu.tmpl
      symlink_env.nu.tmpl
    ruff/
      symlink_pyproject.toml.tmpl
```

**Content of each symlink source file** is the symlink target (a template string):
```
{{ .chezmoi.homeDir }}/.config/Code/User/settings.json
```

**Why this beats Python imperative code:** chezmoi owns the symlinks. `chezmoi
status` detects if one breaks. `chezmoi apply` self-heals on every dotfiles run.
The Python `install` block only runs on explicit `koopa configure user dotfiles`.

**VS Code writes through symlinks in place** (no atomic rename) — the XDG file
stays the single source of truth, chezmoi manages it, VS Code writes through the
App Support symlink without chezmoi knowing or caring.

**Library/ is included on macOS** by `.chezmoiignore` (excluded only on
non-Darwin). The existing `private_Library/` tree (LaunchAgents, KeyBindings)
confirms the pattern works.

**Verify with:**
```sh
KOOPA_COLOR_MODE=dark chezmoi diff --source="${HOME}/.local/share/koopa/opt/dotfiles/chezmoi" \
  ~/Library/Application\ Support/Code/User/settings.json
# mode 120000 in diff = symlink — correct
```

## Sharing One Template Body Across Multiple Targets

Two distinct mechanisms — easy to conflate:

- `symlink_` source-file prefix → the **deployed target** becomes a symlink
  (App Support bridge, above).
- A plain OS symlink **inside the source tree** → several deployed targets
  share one physical template file, each still rendered independently.

### `.chezmoi.sourceFile` distinguishes the caller

When N deployed targets are backed by one real file via plain symlinks in the
source tree (not `symlink_`), chezmoi renders each target from its own source
path — `.chezmoi.sourceFile` reports the **symlink's own path**, not the file
it resolves to. This lets one shared template add a line for only one target:

```
{{- if hasSuffix "code-server-posit/User/settings.json.tmpl" .chezmoi.sourceFile }}
  "terminal.integrated.sendKeybindingsToShell": true,
{{- end }}
```

**Trap:** run `ls -la`, not `cat`/`Read`, before deciding a file is
independent. `cat` follows a symlink transparently and shows correct-looking
content for a file that is actually an alias. Deleting what looks like "the
duplicate" without checking `ls -la` first can delete the one real file
backing several targets. Recoverable with `git restore --source=HEAD -- <path>`,
but cheaper to check first than to fix after.

### `.chezmoitemplates/` partials for structurally-shared content

When several independent template files share a large block but each also has
real content of its own (not just "these targets are byte-identical," which is
the plain-symlink case above), use a chezmoi partial:

```
.chezmoitemplates/<name>.tmpl
```
```
{{ template "<name>.tmpl" . }}
```

Passing `.` gives the partial the caller's root context (`.chezmoi.os`,
`lookPath`, etc.). **Named templates do not inherit the caller's `$var`
scope** — a partial can't read a variable the caller declared with `:=`.
Pass what it needs through the dot argument instead, using sprig's `list`/`dict`
(bundled with chezmoi):

```
{{ template "dracula-pro-theme.tmpl" (list (joinPath .chezmoi.homeDir ".vscode" "extensions" "dracula-theme-pro.theme-dracula-pro-*")) }}
```
Inside the partial, `range .` iterates the passed list.

If a partial's last line is written with no trailing comma (because it's meant
to sit last, right before the closing `}`), every caller must place that
`{{ template }}` call last — document this in the partial's own header
comment, since it isn't visible from the call site.

**Verify semantic equivalence, not text equivalence.** Render each affected
target before and after with `chezmoi execute-template --file`, parse both as
JSON, and diff the *parsed objects* — not the raw text. This ignores harmless
key reordering while still catching a real dropped line. See `koopa-vscode`
for a worked example (three partial tiers across four VS Code-family apps).

## Verifying a Setting Name Is Real Before Trusting It

A config renders as valid JSON even when a key is fake — the app just
silently ignores what it doesn't recognize. Never trust a setting ID because
it looks right or was already there; a fake key found in one file is a sign
worth re-checking anything copied from it.

Verification order, most to least authoritative:
1. The extension's own installed `package.json`:
   `contributes.configuration.properties`.
2. Core app settings: grep the app's own bundled JS
   (e.g. `workbench.desktop.main.js`) for the literal full setting ID.
3. Extension not installed locally — fetch its manifest without installing it:
   ```sh
   curl -fsSL --compressed \
     "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/<publisher>/vsextensions/<name>/latest/vspackage" \
     -o ext.vsix
   unzip -p ext.vsix extension/package.json
   ```
   `--compressed` is required — the endpoint gzips its response, and a bare
   `curl -o` saves the raw gzip bytes as a broken `.vsix`.
4. Core editor.* options often do **not** appear as a full literal string in
   `workbench.desktop.main.js` (the `editor.` prefix gets added at a different
   layer) — a miss there is inconclusive, not proof of absence. Check upstream:
   ```sh
   curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode/<version-tag>/src/vs/editor/common/config/editorOptions.ts"
   ```
   and grep for the short name, without the `editor.` prefix.

A grep **hit** is strong positive evidence. A grep **miss** is weak negative
evidence — confirm against a second source before reporting a setting as fake.

**"Not installed on this machine" ≠ "not a real setting."** A key for an
extension that just isn't installed here (`github.copilot.*` when Copilot
isn't installed) is still correct to keep in dotfiles meant to apply across
machines. Only remove a key when the ID itself is wrong for its own product —
confirmed by one of the sources above, never by the extension's absence alone.

## Diagnosing Spurious chezmoi status / diff Output

**Symptom:** `chezmoi status` shows ` M` on files you haven't changed; `chezmoi
diff` shows a single line flip like `"workbench.colorTheme": "Dracula Pro"` →
`"Dracula Pro (Alucard)"`.

**Cause:** your shell session has a stale `KOOPA_COLOR_MODE` (e.g. `light`) that
doesn't match the current OS mode (`dark`). Templates that branch on
`KOOPA_COLOR_MODE` render differently under your env than they do on disk,
producing a phantom diff.

**Diagnosis:**
```sh
echo "Session: ${KOOPA_COLOR_MODE:-<unset>}"
defaults read -g AppleInterfaceStyle 2>/dev/null || echo "(absent = light)"
cat ~/.cache/koopa/color-mode-applied 2>/dev/null
```
If the session value differs from the OS/marker, the diff is an artifact.

**Fix:** pass the real OS mode explicitly to any chezmoi command:
```sh
KOOPA_COLOR_MODE=dark chezmoi status --source="${HOME}/.local/share/koopa/opt/dotfiles/chezmoi"
KOOPA_COLOR_MODE=dark chezmoi diff   --source="${HOME}/.local/share/koopa/opt/dotfiles/chezmoi"
```
Never trust inherited `KOOPA_COLOR_MODE` in a long-running agent session —
always derive it from `defaults read -g AppleInterfaceStyle` first.

## Go Template Whitespace Trim: `-}}` Eats the Following Newline

A variable-declaration or `stat` call that produces **no output** but uses `-}}` (trim
right) will silently consume the newline *after* the action — welding the next line onto
the end of whatever came before it.

Classic manifestation in tmux configs:

```
# ...comment text.
{{- $someVar := stat "..." -}}
%hidden foo="bar"
```

Rendered output:
```
# ...comment text.%hidden foo="bar"
```

Because the merged line begins with `#`, tmux reads the whole thing as a comment — the
`%hidden` directive is never parsed, the variable is never defined, and every later
`source-file "${foo}"` expands `${foo}` to empty, producing a bogus path.

**Rule:** use `}}` (no trim) on the *right* side of side-effect-free template actions
(variable declarations, `stat` calls) when the *next* line must remain on its own line.
Use `{{-` (trim left) to remove the action's own blank line cleanly. The pattern:

```
{{- $someVar := stat "..." }}
%hidden foo="bar"
```

### Diagnosing "tmux can't find X.conf" errors

The filename in the error is the last thing to investigate. First check whether the
variables referenced in the path are actually defined — search the *deployed* file for
the `%hidden` directive that defines them. A merged comment+directive means the
directive was silently treated as a comment and the variable is undefined. Everything
that expands it then resolves to an empty-prefix path.

### Safe tmux config validation

Parse a tmux config without touching any live session:

```sh
~/.local/share/koopa/bin/tmux -L _koopa_probe -f ~/.config/tmux/tmux.conf \
  start-server \; kill-server
```

Clean exit = no parse errors. Always use koopa's bundled tmux (not `/usr/bin/tmux`)
to match the version assumptions in the config (e.g. `%if #{>=:#{version},3.6}`).

### When targeted apply is safe from an agent session

The `koopa-color-mode` skill warns against running full dotfiles apply from a
long-running agent session because the session's `KOOPA_COLOR_MODE` is frozen. That
warning applies to templates that **branch on `KOOPA_COLOR_MODE`**.

Templates that branch only on `stat` (filesystem presence) are safe to apply from
any session — they read the filesystem, not the inherited env. A targeted apply of
such a template carries no stale-mode risk.
