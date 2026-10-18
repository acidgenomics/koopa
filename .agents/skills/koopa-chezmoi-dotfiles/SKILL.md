---
name: koopa-chezmoi-dotfiles
description: >-
  How koopa manages home dotfiles via chezmoi, source-of-truth layout, the
  explicit --source flag, template-vs-generator ordering, XDG path derivation in
  templates, symlink_ source files for App Support bridges, sharing one template
  body across several deployed targets (.chezmoi.sourceFile, .chezmoitemplates
  partials), verifying a config setting name is real before trusting it,
  diagnosing chezmoi status contamination from stale env, and Go template
  whitespace-trim mechanics (`-}}`/`{{-` eating a following line's indent, or a
  blank line at a partial/include boundary). Use when editing a dotfile, working
  in opt/dotfiles/chezmoi/, debugging a file that reverts on chezmoi apply,
  wiring a chezmoi template, deduplicating near-identical config templates,
  bridging XDG paths to macOS Library/Application Support, a rendered file has a
  stray blank line or a line missing its indent right after a `{{ ... }}`
  action, or a rendered JSON key looks duplicated but is only out of sort order.
---

# koopa Chezmoi Dotfiles

## Source of Truth

The chezmoi source root is:
```
~/.local/share/koopa/opt/dotfiles/chezmoi/
```

**`~/.local/share/chezmoi` must not exist.** Chezmoi is always invoked with an
explicit `--source=<opt/dotfiles>/chezmoi` flag. If `~/.local/share/chezmoi` exists,
it was created accidentally; warn and remove it (after confirming it is not user
data). A bare `chezmoi apply` without `--source` would deploy `dot_*` files into
`~/chezmoi/` instead of `~/`, which is wrong.

**Never run `chezmoi apply` without `--source`** pointing at `opt/dotfiles/chezmoi/`.

**This applies to every chezmoi subcommand, not just `apply`.** A read-only
query run without `--source` (`chezmoi managed`, `chezmoi diff`, `chezmoi
status`) silently checks the wrong tree: chezmoi's own default source dir,
the one that "must not exist" above, instead of erroring. The result looks
like a normal, valid answer instead of a warning, so a false negative is easy
to trust.

Concrete case: `chezmoi managed | grep -i curlrc` (no `--source`) returned
empty, appearing to confirm `~/.curlrc` was an unmanaged, hand-maintained
file. It is fully chezmoi-managed, generated from `dot_curlrc.tmpl`; the
omitted `--source` flag was silently querying an empty, nonexistent default
tree instead of the real one. Re-running with
`--source=~/.local/share/koopa/opt/dotfiles/chezmoi` reversed the finding
immediately, and `chezmoi diff` with the correct source came back empty
(fully in sync), confirming it. Before concluding a file is not
chezmoi-managed, always re-check with the explicit `--source` flag: an
empty or negative result from any bare chezmoi command is not trustworthy
evidence.

## A Missing `--config` Path Creates a Stray State Database

chezmoi puts its persistent-state database next to the config file it reads.
Give it a `--config` path that does not exist, and chezmoi does not error. It
creates a new, mostly empty database beside that path instead.

**The main tree has no `chezmoi.toml`.** Never pass `--config` for it. Only the
work and private trees have one, and koopa's own code gates the flag on
`os.path.isfile()` (`configurers/dotfiles.py`, `configurers/color_mode.py`) so
neither call site ever misfires on the main tree.

Concrete case: a hand-run command copied the work-tree recipe shape,

```sh
chezmoi --config=./chezmoi.toml --source=./chezmoi apply
```

into `opt/dotfiles` (the main tree), where `./chezmoi.toml` does not exist.
chezmoi created `chezmoistate.boltdb` in the repo root: a 128 KB binary blob
holding one stray `entryState` record. The next `git add ./` staged it into
the public `acidgenomics/dotfiles` repo. The real state database always lives
at `~/.config/chezmoi/chezmoistate.boltdb`.

`opt/dotfiles/.gitignore` now ignores `chezmoistate*.boltdb`, so a repeat stays
untracked. But the file still should never be created there: check
`os.path.isfile(config)` (or the shell equivalent) before adding a `--config`
flag to any main-tree command.

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

**Do NOT run `koopa configure user dotfiles` from inside a long-running agent session**:
the session's `KOOPA_COLOR_MODE` may be stale and will clobber theme files. See
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

**Concrete case: git/VS Code diff colors (2026-08).** Three new
templates (`delta/theme.gitconfig.tmpl`, `git/config.tmpl`,
`dracula-pro-diff-colors.tmpl`) each added a `{{ if stat $fragment }}` check
for a Python-generated color file. The generator was placed in
`_configure_dracula_pro_post()` in `opt/dotfiles/install`, which runs *after*
the one `chezmoi apply` call inside `main()`. Result: on the first ever run,
the fragment did not exist yet when the templates rendered, so every one of
them silently fell back to its literal default, and the fragment then got
written moments too late to matter. `koopa configure user dotfiles` reported
"Successfully configured" with no error; the only symptom was `chezmoi
status` still showing those exact files as pending immediately afterward.
This is the same "template runs before post-install generator" trap above,
just self-inflicted a page after reading the warning that describes it
exactly. **Fix:** move the generator call into `_configure_dracula_pro()`
(pre-chezmoi), and swap the `if os.path.isdir(target_dir):` guard for an
unconditional `mkdir(target_dir)` first, since on a first-ever install
chezmoi has not created that directory yet either; an `isdir` guard would
just move the same off-by-one-run bug from "fragment missing" to "directory
missing." tmux's own generated color files avoid this entirely by never
`stat`-ing the generated artifact from a chezmoi template in the first
place: `tmux.conf.tmpl` gates only on the *source* (`$dpProInstalled`) and
emits the color-file path as a plain string; tmux's own `source-file` at
its own startup (long after the whole installer has finished) is what
tolerates a not-yet-generated file gracefully. That's the general shape of
the correct fix when the consuming program has its own "try to read this,
no error if missing" primitive (delta's `[include] path = ...` is another).
VS Code's `workbench.colorCustomizations` has no such primitive: the content
must be present, inline, in the one `chezmoi apply` pass, so moving the
generator earlier is the only option there.

## XDG Paths in Chezmoi Templates

chezmoi has no native XDG variables. Use:
```
{{- $dataHome := env "XDG_DATA_HOME" | default (joinPath .chezmoi.homeDir ".local/share") -}}
{{- $configHome := env "XDG_CONFIG_HOME" | default (joinPath .chezmoi.homeDir ".config") -}}
```

The `.chezmoi.homeDir` fallback is the XDG spec definition, unavoidable and correct.

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
source file is deleted, chezmoi silently ignores the deployed counterpart; it becomes
an untracked orphan that persists indefinitely.

**The correct fix is `.chezmoiremove`**, not a manual `rm`. Add a `.chezmoiremove` file
in the corresponding source directory listing the entries to purge. Chezmoi will then
remove the deployed targets on the next `chezmoi apply`, and keep removing them on every
subsequent apply, preventing stale copies from reappearing.

Keep a **single `.chezmoiremove` at the chezmoi source root** (`chezmoi/.chezmoiremove`),
with all entries as paths relative to `~`. Never nest per-subdirectory `.chezmoiremove`
files: the root file is the one place to audit all removals:

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

`koopa configure user dotfiles` shields a listed file from deletion unless it is chezmoi's own
copy: its hash matches chezmoi's record, or (when there is no record) it equals any past
or present version of the matching non-template source file in the tree's git history.
Anything else is kept and reported as "not written by chezmoi".

This applies to all chezmoi-managed content: dotfiles, Claude Code skills, rules,
settings: anything under `opt/dotfiles/chezmoi/dot_*/`.

Failing to add a `.chezmoiremove` entry means the orphan remains active (e.g. as a
globally-available Claude skill) even though the source no longer tracks it.

## Before Deleting a "Duplicate" Source File, Check for Symlinks (2026-10)

`diff -q` and `cmp` follow symlinks, so a symlink and its target report as
identical. Deleting the target as a "duplicate" leaves the symlink dangling, and
chezmoi then fails on every command that reads the source tree:

```
chezmoi: stat .../dot_config/tmux/colors/dark.conf: no such file or directory
```

This happened with `dot_config/tmux/colors/`: `dark.conf` and `light.conf` are
symlinks (git mode `120000`) to `dracula.conf` and `one-light.conf`. The two
real files looked like unreferenced copies, and `tmux.conf.tmpl` never names
them, because it loads the symlink names.

Check before you delete anything in the source tree:

```sh
ls -l dir/                              # a "->" marks a symlink
git ls-files -s dir/ | grep '^120000'   # mode 120000 is a symlink
find . -type l ! -exec test -e {} \; -print   # dangling links after a delete
```

A file is only a duplicate if no symlink points at it. Treat "not referenced by
name" as weak evidence in a tree that uses symlinks as aliases. If a delete goes
wrong, `git checkout HEAD -- path` restores a tracked file, and
`chezmoi managed --source chezmoi` confirms the source tree is readable again.

## macOS App Support Bridges: Use symlink_ Source Files

macOS apps like VS Code, Cursor, Positron, Antigravity, nushell, and ruff read
config from `~/Library/Application Support/<App>/` rather than the XDG
`~/.config/<App>/` path that chezmoi manages. Bridge these with chezmoi-native
`symlink_` source files, not imperative Python in `opt/dotfiles/install`.

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

**VS Code writes through symlinks in place** (no atomic rename): the XDG file
stays the single source of truth, chezmoi manages it, VS Code writes through the
App Support symlink without chezmoi knowing or caring.

**Library/ is included on macOS** by `.chezmoiignore` (excluded only on
non-Darwin). The existing `private_Library/` tree (LaunchAgents, KeyBindings)
confirms the pattern works.

**Verify with:**
```sh
KOOPA_COLOR_MODE=dark chezmoi diff --source="${HOME}/.local/share/koopa/opt/dotfiles/chezmoi" \
  ~/Library/Application\ Support/Code/User/settings.json
# mode 120000 in diff = symlink, correct
```

## Sharing One Template Body Across Multiple Targets

Two distinct mechanisms, easy to conflate:

- `symlink_` source-file prefix → the **deployed target** becomes a symlink
  (App Support bridge, above).
- A plain OS symlink **inside the source tree** → several deployed targets
  share one physical template file, each still rendered independently.

### `.chezmoi.sourceFile` distinguishes the caller

When N deployed targets are backed by one real file via plain symlinks in the
source tree (not `symlink_`), chezmoi renders each target from its own source
path: `.chezmoi.sourceFile` reports the **symlink's own path**, not the file
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
{{ includeTemplate "<name>.tmpl" . | trimAll "\n" }}
```

Use chezmoi's own `includeTemplate` piped through `trimAll "\n"`, not Go's raw
`{{ template }}` action; see "`-}}` on a Partial's Own Header Comment Eats Its
First Line's Indent" below for the exact whitespace mechanics and why both
ends (the partial's header comment *and* the call site) need their own fix. A
bare `{{ template "X" ARG }}` found while editing is the older style, not a
different mechanism, and should be converted to match.

The same trap applies to a raw `{{ include $path }}` (a dynamic file path, not
a named `.chezmoitemplates` partial) when the included file already ends in
its own trailing newline and the surrounding template also supplies one:
`dot_config/git/config.tmpl` and `dot_config/delta/theme.gitconfig.tmpl` both
had this exact shape (a `stat`-gated diff-color fragment spliced
into a literal/generated `if`/`else`), producing a doubled blank line in one
case and a trailing blank line at EOF in the other. `include`'s return value
is a runtime string, invisible to source-level `{{-`/`-}}` trimming, so the
fix is the same: `{{ include $path | trimAll "\n" }}`.

Passing `.` gives the partial the caller's root context (`.chezmoi.os`,
`lookPath`, etc.). **Named templates do not inherit the caller's `$var`
scope**: a partial can't read a variable the caller declared with `:=`.
Pass what it needs through the dot argument instead, using sprig's `list`/`dict`
(bundled with chezmoi):

```
{{ includeTemplate "dracula-pro-theme.tmpl" (list (joinPath .chezmoi.homeDir ".vscode" "extensions" "dracula-theme-pro.theme-dracula-pro-*")) | trimAll "\n" }}
```
Inside the partial, `range .` iterates the passed list.

If a partial's last line is written with no trailing comma (because it's meant
to sit last, right before the closing `}`), every caller must place that
`includeTemplate` call last; document this in the partial's own header
comment, since it isn't visible from the call site.

**Verify semantic equivalence, not text equivalence.** Render each affected
target before and after with `chezmoi execute-template --file`, parse both as
JSON, and diff the *parsed objects*, not the raw text. This ignores harmless
key reordering while still catching a real dropped line. When "before" means
the last committed state rather than an uncommitted edit still on disk, get it
from a throwaway worktree instead of trusting memory of what HEAD looked like:
```sh
tmp="$(mktemp -d)"
git worktree add --detach "${tmp}/head" HEAD
chezmoi execute-template --source="${tmp}/head/chezmoi" --file "${tmp}/head/chezmoi/<target>.tmpl" > before.json
git worktree remove "${tmp}/head"
```
Pair this with a duplicate-key guard, since `json.load`/`JSON.parse` silently
keep only the last occurrence of a repeated key; a real collision (see "Two
partials cannot each own the same top-level JSON key" below) parses cleanly
and diffs clean, and disappears from view precisely when you need to see it:
```python
import collections, json


def hook(pairs):
    c = collections.Counter(k for k, _ in pairs)
    assert not [k for k, v in c.items() if v > 1], c
    return dict(pairs)


json.loads(rendered_text, object_pairs_hook=hook)
```
See `koopa-vscode` for a worked example (three partial tiers across four
VS Code-family apps).

**A bare `list` argument breaks any partial that also needs `.chezmoi.*`.**
`dracula-pro-theme.tmpl`'s convention (`(list (joinPath .chezmoi.homeDir ...))`)
works because that partial only ever does `range .` over the list, nothing
else. A partial that *also* needs `.chezmoi.homeDir` (for example, to locate
a generated fragment under `XDG_CONFIG_HOME`) breaks with `can't evaluate
field chezmoi in type []interface {}`, because `.` is now bound to the list,
not the caller's root context. Pass a `dict` instead once a partial needs
more than one thing from the caller:
```
{{ includeTemplate "my-partial.tmpl" (dict "homeDir" .chezmoi.homeDir "globs" (list ...)) | trimAll "\n" }}
```
and read `.homeDir`/`.globs` inside the partial instead of `.`/`.chezmoi.homeDir`.

**Two partials cannot each own the same top-level JSON key.** If partial A
emits `"workbench.colorCustomizations": { ... }` and partial B (called by the
same target) emits its own `"workbench.colorCustomizations": { ... }`, the
rendered text is *syntactically* valid JSON with the key repeated twice, but
`JSON.parse`/`json.load` keeps only the **last** occurrence, silently
discarding whichever came first. Caught by the exact verification method
above (parse before/after, diff the parsed objects): Positron's
`colorCustomizations` object appeared as expected after adding a new call,
but Code/Antigravity/Cursor's did not, because `vscode-fork-common.tmpl`,
called *after* the new partial in those three files, already defined the
same key with different (unrelated) content. **Fix:** make the partial emit
only the *inner* content (no outer key, no wrapping braces, no leading or
trailing comma), and splice it into whichever `"workbench.colorCustomizations"`
object the caller already has (or opens fresh, if it has none); never let
two independent sources both try to own the same top-level key.

## Verifying a Setting Name Is Real Before Trusting It

A config renders as valid JSON even when a key is fake: the app just
silently ignores what it doesn't recognize. Never trust a setting ID because
it looks right or was already there; a fake key found in one file is a sign
worth re-checking anything copied from it.

**If the app is open on the rendered file, its own inline diagnostics
outrank every source below for an enum-constrained value.** A live audit
of a rendered `settings.json` in Positron caught
`"python.analysis.diagnosticsSource": "Pyright"` as genuinely invalid;
Pylance's own hover gave the exact current valid set
(`Pylance`/`Pylance + Pyright`/`Pylance + Pyrefly`) directly, no grepping
required. A bundle grep for `Pyright` would have been a false-negative-proof
trap here: the string is all over the bundle as the underlying engine name,
which looks like positive evidence for a value the schema no longer accepts
standalone. When the editor hands you the valid values, use them verbatim;
don't re-derive them from a grep.

**The mirror case, a bare "Property X is not allowed" for a key that *is*
real, is not equally trustworthy.** The same audit flagged
`diffEditor.removedLineBackground` as disallowed in a settings.json that
chezmoi had just written from outside the editor; a bundle grep and an
upstream source check (`src/vs/platform/theme/common/colors/editorColors.ts`)
both confirmed the color is currently registered. Unlike an enum's explicit
value list, a plain "not allowed" on an `additionalProperties`-style schema
carries no such self-evidencing detail, and the editor's JSON language
service can lag an external file write. Cross-check a bare "not allowed"
against a second source (tiers below, or a reload of the window) before
concluding the key is fake; don't take it at face value the way an enum's
"Valid values: ..." can be.

Verification order, most to least authoritative:
1. The extension's own installed `package.json`:
   `contributes.configuration.properties`. Also check `contributes.colors`
   here for theme color IDs, not just settings: `gitDecoration.*` (and every
   other git-decoration color) is contributed by the bundled Git extension's
   own `package.json`, not present anywhere in the core `workbench.desktop.main.js`
   bundle. A miss in the core bundle for a `gitDecoration.*`/similar
   extension-namespaced ID is not evidence it's fake; check tier 1 first for
   anything that isn't a bare `editor.*`/`workbench.*` core ID.
2. Core app settings: grep the app's own bundled JS
   (e.g. `workbench.desktop.main.js`) for the literal full setting ID.
3. Extension not installed locally: fetch its manifest without installing it:
   ```sh
   curl -fsSL --compressed \
     "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/<publisher>/vsextensions/<name>/latest/vspackage" \
     -o ext.vsix
   unzip -p ext.vsix extension/package.json
   ```
   `--compressed` is required: the endpoint gzips its response, and a bare
   `curl -o` saves the raw gzip bytes as a broken `.vsix`.
4. Core editor.* options often do **not** appear as a full literal string in
   `workbench.desktop.main.js` (the `editor.` prefix gets added at a different
   layer); a miss there is inconclusive, not proof of absence. Check upstream:
   ```sh
   curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode/<version-tag>/src/vs/editor/common/config/editorOptions.ts"
   ```
   and grep for the short name, without the `editor.` prefix.

A grep **hit** is strong positive evidence. A grep **miss** is weak negative
evidence; confirm against a second source before reporting a setting as fake.

### A setting's value type can change under you (2026-10)

A key can be real and still carry the wrong *type*. `extensions.autoUpdate` was a
boolean. In VS Code 1.141 its schema is a string with the values `"on"` and
`"off"` (default `"on"`). The template set `false`; Positron rewrote that to `"off"`
in the deployed file, which showed up as `MM` in `chezmoi status` with a one-line
type flip as the whole diff. Treat that pattern, an app editing one value of a file
chezmoi wrote, as the app telling you the current schema.

Read a core setting's schema from the app bundle, not from memory:

```sh
grep -a -o -E 'extensions\.autoUpdate["]?:\{[^}]{0,420}\}' \
    "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.js"
```

Positron's bundle is formatted differently and the same pattern found nothing, so
fall back to the value the app wrote. The 2026-10 resolution was to drop the key
(the user wanted extensions to auto-update, which is the default), not to change
its type in four apps whose versions differ.

### Audit a whole rendered settings file against the installed manifests (2026-10)

Tier 1 scales: load every installed extension's `package.json` once and check
all the extension-owned keys in a rendered `settings.json` in one pass. Do this
before you trust any review's claim that a key is dead or renamed, including a
subagent's: a model's memory of option names is the weakest source here.

A manifest property can carry `deprecationMessage`, and that text names the
replacement setting. The editor flags only some deprecated keys, so the scan also
finds the ones it stays quiet about. A 2026-10 pass over the R extension (3.0.1)
found `r.rterm.*` to `r.consolePath`, `r.rtermSendDelay` to
`r.consoleSendDelay`, `r.rpath.*` to `r.executablePath` (the editor never
flagged this one), and `r.plot.useHttpgd` to `r.plot.backend` with the enum
`auto|standard|httpgd|jgd`. Three more keys had no manifest entry at all
(removed upstream), so the fix was to delete them, not rename them.

```sh
chezmoi execute-template --source chezmoi \
    < chezmoi/dot_config/Code/User/settings.json.tmpl > "${tmp}/Code.json"
python3 -I - "${tmp}/Code.json" \
    "${HOME}/.vscode/extensions" \
    "/Applications/Visual Studio Code.app/Contents/Resources/app/extensions" <<'PY'
import glob, json, os, sys
settings = json.load(open(sys.argv[1]))
props = {}
for base in sys.argv[2:]:
    for pj in glob.glob(os.path.join(base, '*', 'package.json')):
        conf = json.load(open(pj)).get('contributes', {}).get('configuration', [])
        for c in (conf if isinstance(conf, list) else [conf]):
            props.update(c.get('properties') or {})
core = ('editor.', 'files.', 'workbench.', 'terminal.', 'window.', 'git.', '[')
for key in sorted(k for k in settings if not k.startswith(core)):
    p = props.get(key)
    if p is None:
        print('NOT FOUND ', key)
    elif p.get('deprecationMessage'):
        print('DEPRECATED', key, '|', p['deprecationMessage'])
PY
```

Scan two places per app: the user extensions directory (`~/.vscode/extensions`,
`~/.positron/extensions`, `~/.cursor/extensions`) **and** the app's own bundled
extensions (`<App>.app/Contents/Resources/app/extensions`). Skip core prefixes:
no extension defines them. Bundled extensions such as Copilot live only in the
app: VS Code 1.141.2 ships `extensions/copilot/package.json` (GitHub Copilot
Chat 0.69.0), which defines `github.copilot.enable` and
`github.copilot.nextEditSuggestions.enabled`. A first version of this scan read
only the user directory and reported both as `NOT FOUND`, and the claim "bundled,
so real" was made before anyone checked. Scanning the bundled directory settles
it. A `NOT FOUND` for an app-specific prefix (`antigravity.*`) means the app is
not installed here, so the keys stay unverified, not wrong.

**"Not installed on this machine" ≠ "not a real setting."** A key for an
extension that just isn't installed here (`github.copilot.*` when Copilot
isn't installed) is still correct to keep in dotfiles meant to apply across
machines. Only remove a key when the ID itself is wrong for its own product,
confirmed by one of the sources above, never by the extension's absence alone.

## Diagnosing Spurious chezmoi status / diff Output

**Symptom:** `chezmoi status` shows ` M` on files you haven't changed; `chezmoi
diff` shows a single line flip like `"workbench.colorTheme": "Dracula Pro"` →
`"Dracula Pro (Alucard)"`. At its most alarming, this can list two dozen
completely unrelated files at once (every theme-aware config in the source
tree) right after an otherwise-unrelated targeted apply; it looks like that
apply broke something far outside its scope, but it's the same single-cause
env mismatch, not two dozen new bugs.

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
Never trust inherited `KOOPA_COLOR_MODE` in a long-running agent session:
always derive it from `defaults read -g AppleInterfaceStyle` first.

**Measured again, 2026-10, from an agent shell:** `KOOPA_COLOR_MODE=light` was
inherited while the OS was Dark. `chezmoi status` listed 27 files, among them
`bat`, `bottom`, `btop`, `cheat`, `atuin` and `alacritty`. With
`KOOPA_COLOR_MODE=dark` it listed 7, and those 7 were the real unapplied edits.
So the count to trust is the one under the correct mode. Run it twice (inherited,
then explicit) and subtract. A work tree adds a second false alarm:
`encrypted_*` sources print `age: error: no identity matched any of the
recipients` because the agent shell has no age identity; see `koopa-dotfiles`,
"Work-host layering".

## A `stat`-Gated Fallback Branch Causes Perpetual Drift If the Stat Target Is Transient

`{{ if stat X }}A{{ else if lookPath Y }}B{{ end }}` looks like a reasonable
"prefer X, fall back to Y" pattern, but if `X` is something that comes and
goes over time (a per-project `~/.venv`, not a permanently-installed tool),
every render after `X`'s existence changes produces a different result than
whatever is currently deployed, reported as `chezmoi status` drift, even
though nothing about the *template* changed. Two settings.json templates
(`Positron/User/settings.json.tmpl`, `dot_vscode-server/data/Machine/settings.json.tmpl`)
had exactly this shape for `python.defaultInterpreterPath`: `stat
~/.venv/bin/python3`, else `lookPath "python3"`. The deployed value reflected
whichever branch was true the last time `chezmoi apply` happened to run;
`~/.venv` stopped existing sometime after that, so every fresh render
disagreed with the stale deployed value.

**Fix, when the intent is "only set this if X exists, otherwise let the app
decide its own default":** drop the fallback branch entirely rather than
substituting a second unstable-over-time value:
```
{{- if stat (joinPath .chezmoi.homeDir ".venv" "bin" "python3") }}
  "python.defaultInterpreterPath": "{{ .chezmoi.homeDir }}/.venv/bin/python3",
{{- end }}
```
No `else`. When `~/.venv` doesn't exist, the key is simply absent from the
rendered JSON rather than pointing at some other, less-specific value that
would just as easily fall out of sync the next time something on the machine
changes. The general principle: a `stat`/`lookPath` condition that's expected
to be permanently one way or the other (Dracula Pro installed or not; an app
installed or not) is safe to branch on. A condition whose truth value is
expected to change during normal, ordinary use of the machine (a project venv
existing) is not: branching on it either produces perpetual drift, or, if
the intent really is "track whatever the interpreter should be right now,"
belongs to the *app's own dynamic detection* (e.g. VS Code's own Python
extension), not a value baked into chezmoi-rendered `settings.json` at all.

## Go Template Whitespace Trim: `-}}` Eats the Following Newline

A variable-declaration or `stat` call that produces **no output** but uses `-}}` (trim
right) will silently consume the newline *after* the action, welding the next line onto
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

Because the merged line begins with `#`, tmux reads the whole thing as a comment: the
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
variables referenced in the path are actually defined; search the *deployed* file for
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

### A tmux upgrade can change a default your theme never set (2026-10)

If the status bar looks different after a tmux update and the config did not
change, the default moved. tmux 3.8 changed `window-status-current-style` from
`default` to `underscore`, so the active window was underlined. The same release
did it to `pane-status-current-style` and `session-status-current-style`, and it
added a `theme` system (`themegreen`, `dark-theme-*`) that restyles any
`*-style` option the config leaves unset.

Read the real defaults from a throwaway server with no config, and compare them
with what the theme files set:

```sh
~/.local/share/koopa/bin/tmux -L _koopa_probe -f /dev/null \
  start-server \; show-options -gw \; show-options -g | grep -- '-style'
~/.local/share/koopa/bin/tmux -L _koopa_probe kill-server
```

Fix a changed default in `tmux.conf.tmpl`, **above** the theme `source-file`
lines, not in the generated Dracula Pro files (never hardcode Pro values; see the
theme-colors rule). After `chezmoi apply`, press the prefix and `r` to reload.

### When targeted apply is safe from an agent session

The `koopa-color-mode` skill warns against running full dotfiles apply from a
long-running agent session because the session's `KOOPA_COLOR_MODE` is frozen. That
warning applies to templates that **branch on `KOOPA_COLOR_MODE`**.

Templates that branch only on `stat` (filesystem presence) are safe to apply from
any session: they read the filesystem, not the inherited env. A targeted apply of
such a template carries no stale-mode risk.

### `-}}` on a Partial's Own Header Comment Eats Its First Line's Indent

The blank-line artifact at a `.chezmoitemplates` call site is covered above
("`.chezmoitemplates/` partials for structurally-shared content", use
`includeTemplate ... | trimAll "\n"`, never a bare `{{ template }}` action).
That fix cleans up the *call site*. A second, independent instance of this
same `-}}` rule can still break the *partial's own* first content line, and
`trimAll` does not fix it.

A partial's header-comment block commonly closes with `*/ -}}` right before
the partial's first real content line:

```
{{- /*
  ...docs...
*/ -}}
  "editor.autoClosingBrackets": "never",
```

`-}}` trims *all* trailing whitespace, which is the newline **and** the two
leading spaces of the next line; the rendered key lands at column 0 instead
of 2-space indent. `trimAll "\n"` at the call site only strips newline
characters, never spaces, so it cannot repair this; the fix has to be in the
partial itself. Every VS Code-family `settings.json.tmpl` partial in koopa had
this bug (`vscode-universal-common.tmpl`, `vscode-fork-common.tmpl`,
`dracula-pro-theme.tmpl`, `dracula-pro-diff-colors.tmpl`), each rendering its
first key unindented.

**Fix:** close the header comment with `*/}}` (no space, no dash) instead, so
the newline and indentation of the first content line survive intact: the
leading blank line this leaves behind is exactly what the call site's
`trimAll "\n"` removes. `*/ }}` (space, no dash) is a lexer error: `comment
ends before closing delimiter`. The `*/` token must be followed immediately
by `}}` or `-}}` with no space in between. A non-comment action such as
`{{- end }}` has no such restriction; just drop the trailing `-`.

Verify with `chezmoi execute-template --file`, not by re-reading the source:
render before and after, `grep -n -e '^$' -e '^"'` the output for leftover
artifacts, and diff the *parsed* JSON objects (not the raw text) to confirm no
key was dropped.

### Inline `if`/`else` With No Downstream `trimAll`: Trim Left Only, Never Right

The two fixes above both rely on a `trimAll "\n"` at a call site to mop up
whatever blank line the fix leaves behind. An inline `{{ if }}...{{ else
}}...{{ end }}` that substitutes one indented line for another *within* a
single file, not through a partial, has no such call site, so the same
`-}}`-on-both-sides instinct produces a bug with no downstream fix available.

Found in `dot_config/nushell/config.nu.tmpl`, picking a `color_config` value by
`KOOPA_COLOR_MODE`:

```
{{ if eq (env "KOOPA_COLOR_MODE") "dark" -}}
  color_config: $dark_theme
{{- else -}}
  color_config: $light_theme
{{- end }}
```

`-}}` on the `if` line eats the newline **and** the 2-space indent of the next
line, same as the partial-header bug: `color_config` renders at column 0.
Naively dropping the trailing `-` (`{{ if ... }}`) fixes the indent but
reintroduces a blank line: the `if` action itself consumes none of the
newline between it and the content line, so that newline survives as a
literal blank line with nothing to trim it away.

**Fix:** trim left only, never right, on every branch keyword:

```
{{- if eq (env "KOOPA_COLOR_MODE") "dark" }}
  color_config: $dark_theme
{{- else }}
  color_config: $light_theme
{{- end }}
```

`{{-` on `if`/`else`/`end` eats the *preceding* line's own trailing newline
(the one that already terminates the previous literal line), so the keyword
itself contributes no extra line. The untrimmed `}}` then leaves the
*following* line's newline and indent completely alone. Net effect: exactly
one newline and the correct indent, every time, no matter which branch is
taken. `dot_config/doom/config.el.tmpl` already uses this exact pattern
correctly for its `auto-dark-theme` `if`/`else`/`end` chains; grep for
`{{- if` there for a second confirmed-correct example.

This is a third, distinct shape from the two above: a partial boundary
(header comment, or call site) can lean on `trimAll` to clean up either
side's mess; a bare inline conditional with no such downstream fix has
to get the trim balance exactly right the first time: left-only, on every
keyword, full stop.

## Auditing a Chezmoi Tree for the Whitespace-Trim Bug Family

A repeatable recipe for sweeping every `.tmpl` file in a chezmoi source tree for
the three bug shapes above:

1. **Static scan for indent-loss.** For every line ending in `-}}`, check
   whether the *next* line starts with leading whitespace followed by
   non-`{{` content; that whitespace is exactly what `-}}` would eat. A short
   Python script line-scanning every `*.tmpl` under the tree root with a
   regex (`-\}\}\s*$` on one line, `^( +)(?!\{\{)(\S.*)$` on the next) finds
   every candidate in seconds; false positives are lines where the next
   content already starts at column 0 (nothing to lose; see
   `dot_config/zed/settings.json.tmpl` and `dot_spacemacs.tmpl` for confirmed
   safe examples of exactly this shape).
2. **Find every partial/include boundary.** `grep -rn -E
   '\{\{-?\s*(include|includeTemplate|template)\b' --include='*.tmpl'` across
   the tree. Any bare `{{ template ... }}` is the older, buggy style (convert
   it). Any `{{ include $path }}` or `{{ includeTemplate ... }}` without a
   trailing `| trimAll "\n"` is a candidate for the doubled-newline bug; check
   whether the included content already ends in its own trailing newline.
3. **Render, don't reason by eye.** Manually tracing `{{-`/`-}}` trim rules
   across several chained `if`/`else`/`end` actions is error-prone even for
   the person who wrote this section; use `chezmoi execute-template --file`
   to get ground truth. For files with conditional branches, force each branch
   with env overrides (`KOOPA_COLOR_MODE=dark|light`, `XDG_DATA_HOME=/dev/null`
   or a nonexistent path to force a `stat` check false) since `execute-template`
   is read-only and touches no real files.
4. **Check for artifacts with `grep`/`awk`, not eyeballing.** `grep -n -e '^$'
   -e '^"'` catches blank lines and column-0 JSON keys. For non-JSON formats
   (gitconfig, nu, elisp) use `awk 'BEGIN{b=0} /^$/{b++; if(b>1) print NR}
   !/^$/{b=0}'` to catch doubled blank lines, and `od -c | tail` to check for
   an unwanted trailing blank line at EOF.
5. **Confirm content, not just formatting, is unchanged.** For JSON targets,
   parse before/after renders and diff the objects (see "Verify semantic
   equivalence" above). For non-JSON formats, `git diff` the *source* `.tmpl`
   edit itself and confirm every changed line is a bare control token
   (`{{`, `}}`, `-}}`, `{{-`, `template`→`includeTemplate`, `| trimAll`), never
   a literal value.
6. **Apply narrowly.** `chezmoi diff --source=<tree> <specific target(s)>`
   before `chezmoi apply --source=<tree> <specific target(s)>`; never a bare
   `chezmoi apply` with no target list, and never `koopa configure user
   dotfiles` from an agent session (stale `KOOPA_COLOR_MODE`, see above).

This exact recipe found and fixed one bug in each of the two patterns above in
`opt/dotfiles/chezmoi` (`dot_config/nushell/config.nu.tmpl`,
`dot_config/delta/theme.gitconfig.tmpl`, `dot_config/git/config.tmpl`) beyond
the four VS Code-family files already covered, and confirmed a second,
smaller chezmoi tree (a private work-tree source with no `.chezmoitemplates`
partials at all) was clean. Run the same sweep against any other chezmoi tree
under management; the recipe generalizes.

## Canonicalizing an Assembled JSON Template: `fromJson | toPrettyJson`

When a JSON target is assembled from several `.chezmoitemplates` calls back to
back, the result is a series of independently-sorted blocks, not one globally
sorted file: a key family split across two blocks (`editor.autoClosing*`
appearing once per block) reads as duplication even though every key is
unique. This is a *different* symptom from the whitespace-trim family above:
nothing is malformed, the file just isn't canonically ordered.

**Fix:** move the whole assembled body into its own partial, and reduce the
deployed target to one line that re-serializes it:
```
{{ includeTemplate "<name>-body.tmpl" . | fromJson | toPrettyJson | trimAll "\n" }}
```
chezmoi 2.72's `toPrettyJson` parses the string and re-emits it 2-space
indented, with every key sorted byte-wise (`enableFileLinks` before
`enableMultiLinePasteWarning`; capital letters before lowercase at the same
position) and without HTML-escaping `&`/`<`/`>`. This sidesteps the entire
whitespace-trim bug family for that file: blank lines and lost indent at a
partial boundary stop mattering, because the layout is regenerated from the
parsed object rather than concatenated as text.

**The `| trimAll "\n"` at the end is not optional, and its absence is a new,
easy-to-miss bug shape.** `toPrettyJson`'s own output already ends in `\n`; a
one-line wrapper file on disk carries its own trailing `\n` too. Omit
`trimAll "\n"` and every rendered target ends `}\n\n`: a trailing blank line,
same defect as the header-comment and inline-`if` variants above, just at
EOF instead of a boundary. This is the fourth variant of the trim-marker
family: the first three are all about `-}}`/`{{-` eating whitespace at
render time; this one is two independently-correct trailing newlines
stacking after render. `chezmoi execute-template --file` plus `tail -c 3 |
od -c` (not a var-captured `$(...)`, which bash strips trailing newlines
from) catches it.

**Trade-offs this introduces**, beyond the ones already accepted for any
`.chezmoitemplates` partial:
- JSON comments become impossible in the file. Confirm none exist first
  (`grep -n '^\s*//'` across the affected `.tmpl` files).
- A duplicate key becomes invisible in the output: `fromJson` silently keeps
  the last occurrence. Guard with the `object_pairs_hook` counter above; do
  not rely on eyeballing the render.
- A malformed partial (bad trailing comma, etc.) now raises a hard template
  error at render time instead of deploying a silently broken file. This is
  an improvement, not a regression.
- A source partial that must open/close a JSON object spanning an
  `includeTemplate` boundary (for example, a partial wrapping
  `dracula-pro-diff-colors.tmpl` inside its own
  `"workbench.colorCustomizations": { ... }`) still can't have every one of
  its *own* lines in alphabetical order in the source; `toPrettyJson` fixes
  the *output* order regardless, so don't try to "fix" the source order in a
  case like this; it's structural, not a mistake.

See `koopa-vscode`, "Global key sort via `fromJson | toPrettyJson`", for the
worked example (four apps, one genuine two-key ordering mistake caught by
review, and the doubled-trailing-newline bug caught separately after apply).
