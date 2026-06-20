---
name: koopa-vscode
description: >
  Quarto VS Code plugin and LuaLS (.luarc.json) configuration for the koopa
  project. Use when editing .luarc.json, understanding how Quarto generates it,
  or making project-local VS Code extension config portable across machines.
---

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
