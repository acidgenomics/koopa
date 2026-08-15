---
name: koopa-vscode
description: >-
  VS Code terminal font configuration, Nerd Font glyph debugging, the shared
  settings.json.tmpl partial architecture across Code/Antigravity/Cursor/Positron,
  and Quarto/LuaLS setup for koopa. Use when debugging missing terminal glyphs
  (tofu), changing the VS Code terminal or editor font, understanding the App
  Support symlink bridge for editor settings, adding or moving a setting across
  the VS Code-family templates, checking whether a setting name is real before
  adding it, editing .luarc.json, or making VS Code config portable across
  machines.
---

# koopa VS Code Configuration

## VS Code Terminal Font and Nerd Font Glyphs

### The App Support symlink bridge

On macOS, chezmoi manages VS Code settings at the XDG path
`~/.config/Code/User/settings.json`. VS Code reads from
`~/Library/Application Support/Code/User/settings.json`. koopa bridges these
with a chezmoi `symlink_` source file — the App Support path is a symlink to the
XDG file. The same pattern applies to Cursor, Positron, Antigravity, nushell,
and ruff. See `koopa-chezmoi-dotfiles` for the full layout.

VS Code writes settings back through the symlink in place (no atomic rename), so
the XDG file remains the single source of truth.

### Diagnosing missing terminal glyphs (tofu)

Nerd Font glyphs (e.g. starship's battery `󰂃`, U+F0083) render correctly in
Ghostty but show as tofu in the VS Code integrated terminal. This is always a
**terminal font** problem, never a starship config problem.

**Step 1 — verify the font family name.** VS Code (Electron/Chromium) matches
the macOS CoreText registered family name exactly. Ghostty uses its own fuzzy
font discovery and accepts long descriptive names. They are different resolvers.

Find the real family name:
```sh
mdls -raw -name com_apple_ats_name_family \
  ~/Library/Fonts/JetBrainsMonoNLNerdFontMono-Regular.ttf
# → JetBrainsMonoNL NFM     ← this is what VS Code needs
```

Do NOT use the long descriptive name (e.g. `JetBrainsMonoNL Nerd Font Mono`) in
VS Code settings — it does not resolve via CoreText and silently falls back to the
base non-Nerd font.

**Verified CoreText family names for installed JetBrains variants:**
| File | VS Code family string |
|---|---|
| `JetBrainsMonoNLNerdFontMono-Regular.ttf` | `JetBrainsMonoNL NFM` |
| `JetBrainsMonoNLNerdFont-Regular.ttf` | `JetBrainsMonoNL NF` |
| `JetBrainsMonoNerdFontMono-Regular.ttf` | `JetBrainsMono NFM` |
| `JetBrainsMonoNL-Regular.ttf` | `JetBrains Mono NL` |
| `JetBrainsMono[wght].ttf` | `JetBrains Mono` |

**Step 2 — confirm the setting reaches VS Code.** VS Code reads from
`~/Library/Application Support/Code/User/settings.json`, not the XDG path.
Verify the symlink is in place:
```sh
ls -l ~/Library/Application\ Support/Code/User/settings.json
# should show -> /Users/<name>/.config/Code/User/settings.json
```
If it's a plain file, the chezmoi symlink bridge hasn't run yet. Run
`koopa configure user dotfiles` from a normal terminal.

**Step 3 — check what VS Code is actually reading:**
```sh
grep "fontFamily" ~/Library/Application\ Support/Code/User/settings.json
```

### Font configuration in chezmoi templates

The four VS Code-family editor templates live under
`opt/dotfiles/chezmoi/dot_config/{Code,Cursor,Positron,Antigravity}/User/settings.json.tmpl`.
The font keys below are NOT written out in each file — they live once in
`.chezmoitemplates/vscode-universal-common.tmpl` (see "Shared settings.json
architecture" below). Don't add a fourth copy; edit the partial.

Correct font settings (no ligatures, Nerd Font Mono for glyph coverage):
```json
"editor.fontFamily": "'JetBrainsMonoNL NFM', 'JetBrains Mono', monospace",
"editor.fontLigatures": false,
"terminal.integrated.fontFamily": "'JetBrainsMonoNL NFM', 'JetBrains Mono', monospace",
```

`NL` = No-Ligatures build. `NFM` = Nerd Font Mono (single-width glyphs, correct
for terminals). The fallback `'JetBrains Mono'` ensures the editor stays usable
if the Nerd Font is not installed.

### Shared settings.json architecture

Code, Antigravity, and Cursor overlap by ~85%; Positron is structured
differently by design (its file started at 46 lines and has only grown since —
verify with `git log --follow -- .../Positron/User/settings.json.tmpl` before
assuming a gap is drift). Three `.chezmoitemplates/` partials hold the overlap
instead of four flat files:

| Partial | Covers | Called by |
|---|---|---|
| `vscode-fork-common.tmpl` | ~130 settings byte-identical across Code/Antigravity/Cursor | Code, Antigravity, Cursor — always LAST (its final line has no trailing comma) |
| `vscode-universal-common.tmpl` | 17 settings verified byte-identical across all four apps | Code, Antigravity, Cursor, Positron |
| `dracula-pro-theme.tmpl` | Theme-name detection, parameterized by each app's own extension-glob path via `list` | all four |

Each app's own `settings.json.tmpl` keeps only its real deltas: Code's
`chat.*`/`claudeCode.*`/`github.copilot.*`/`githubPullRequests.*`, Antigravity's
`antigravity.*` keys, Positron's independent structure. `[json]`/`[python]`/`[r]`/
`[toml]`/`air.*` stay duplicated inline in Code/Antigravity/Cursor rather than
going in a partial — `[toml]` differs by one line between them, and keeping the
language blocks together at the top of each file reads better than the few
duplicated lines would cost.

See `koopa-chezmoi-dotfiles` for the two general mechanisms this relies on
(`.chezmoi.sourceFile` for symlinked-source targets, `.chezmoitemplates` for
structurally-shared content) and for how to verify a setting name is real
before adding it to any of these files.

### Avoiding a write race on settings.json

`settings.json` is a contested file: chezmoi writes it, VS Code writes it, and
koopa's background `com.koopa.color-mode-sync` watcher re-renders it on every
OS dark/light flip if the template contains `KOOPA_COLOR_MODE`.

**Rule:** do NOT put `KOOPA_COLOR_MODE`-conditional logic in `settings.json.tmpl`.
Instead use VS Code's native OS-appearance following:
```json
"window.autoDetectColorScheme": true,
"workbench.preferredDarkColorTheme": "Dracula Pro",
"workbench.preferredLightColorTheme": "Dracula Pro (Alucard)",
```
With these three keys, VS Code switches themes on OS appearance changes by itself.
The `KOOPA_COLOR_MODE` branch is redundant and causes the race.

If `workbench.colorTheme` is set conditionally in any editor template, remove it.
Verify with:
```sh
grep -l "KOOPA_COLOR_MODE" \
  opt/dotfiles/chezmoi/dot_config/*/User/settings.json.tmpl
# expect: no output
```

# koopa VS Code Plugin Configuration

## `.luarc.json` — LuaLS config for Quarto

### What it is

`.luarc.json` at the koopa repo root is a lua-language-server (LuaLS) config
file read by the VS Code Lua extension (`sumneko.lua`). It points LuaLS at
Quarto's Lua type definitions, enabling completion and diagnostics when editing
Quarto Lua filters.

koopa tracks **no first-party Lua source** (`git ls-files '*.lua'` → empty).
This file is only useful if you write Quarto Lua filters.

### The Quarto Generator problem

By default Quarto auto-generates `.luarc.json` and self-adds it to `.gitignore`.
The `Generator` key at the top of the file is the signal: when present, Quarto
**owns** the file and will re-clobber it with absolute, version-pinned paths
(`/Users/<name>/.local/share/koopa/app/quarto/<version>/...`) on every Quarto
upgrade or re-init.

**To take manual control:** remove the `Generator` key entirely. The block itself
says: *"Remove the 'Generator' key to manage this file's contents manually."*
Without `Generator`, Quarto leaves the file alone.

### Portable path pattern

LuaLS resolves relative paths in `Lua.workspace.library` and
`Lua.runtime.plugin` against the **workspace root** (verified in
`script/workspace/workspace.lua` `getAbsolutePath(scp.uri, path)`). Since
`.luarc.json` sits at the koopa repo root, repo-relative paths work and contain
no username or version pin.

koopa exposes a **version-stable symlink** `opt/quarto → app/quarto/<version>`
that is repointed on every Quarto upgrade. Use this instead of the versioned
`app/quarto/<x.y.z>/...` path.

### Canonical committed form

```json
{
  "Lua.runtime.version": "Lua 5.3",
  "Lua.workspace.checkThirdParty": false,
  "Lua.workspace.library": [
    "opt/quarto/share/lua-types"
  ],
  "Lua.runtime.plugin": "opt/quarto/share/lua-plugin/plugin.lua",
  "Lua.completion.showWord": "Disable",
  "Lua.completion.keywordSnippet": "Both",
  "Lua.diagnostics.disable": [
    "lowercase-global",
    "trailing-space"
  ]
}
```

No `Generator` key → Quarto won't regenerate. No absolute path → portable
across any machine and any koopa install. No `app/quarto/<version>` pin →
survives Quarto upgrades automatically.

### .gitignore

The auto-generated file adds `/.luarc.json` to `.gitignore`. When taking manual
control, remove that line so git can track it.

### LuaLS placeholder support (`.luarc.json` context)

LuaLS implements its own path expansion in `script/files.lua`
(`resolvePathPlaceholders` + `util.expandPath`). These work directly in
`.luarc.json` (not via VS Code's substitution engine):

| Placeholder | Resolves to |
|---|---|
| `${workspaceFolder}` | workspace root (equivalent to a bare relative path) |
| `${env:VAR}` | `os.getenv("VAR")` |
| `${3rd}` | LuaLS built-in 3rd-party meta directory |
| `~` | user home (via `util.expandPath`) |

Plain `$VAR` (no `env:` prefix) is **not** expanded. VS Code-only substitutions
like `${userHome}` or `${fileDirname}` are **not** supported in `.luarc.json`.
Prefer bare relative paths over placeholders when the target is inside the repo.
