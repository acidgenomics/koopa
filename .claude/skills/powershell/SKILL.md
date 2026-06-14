---
name: powershell
description: >
  PowerShell (pwsh 7+) activation architecture, starship integration, and color-mode
  sync in koopa. Use when writing or debugging lang/powershell/ files, editing
  activate-*.ps1 functions, adding prompt-tool support (starship, zoxide), integrating
  OS appearance detection, or porting shell logic from bash/zsh/fish to PowerShell.
---

# PowerShell in koopa

## Activation Architecture

```
Microsoft.PowerShell_profile.ps1.tmpl  (chezmoi source → ~/.config/powershell/)
  └── . ~/.local/share/koopa/activate.ps1
        └── . lang/powershell/include/header.ps1
              ├── dot-sources ALL *.ps1 under lang/powershell/functions/ (recursively)
              └── __koopa_activate_koopa
                    ├── _koopa_activate_bootstrap
                    ├── PATH / MANPATH additions
                    ├── _koopa_activate_{bat,conda,dircolors,direnv,docker,fzf,…}
                    ├── Homebrew (macOS) / Scoop+WinGet (Windows)
                    ├── _koopa_activate_difftastic
                    ├── _koopa_activate_aliases
                    ├── _koopa_activate_starship   ← line 79
                    └── _koopa_activate_color_mode_sync  ← line 80, wraps starship prompt
```

The profile itself only: (1) sources `activate.ps1`, (2) sets PSReadLine syntax
colors via `KOOPA_COLOR_MODE` chezmoi branch, (3) sets `FZF_DEFAULT_OPTS`.

**Guard variables:** `KOOPA_ACTIVATE=1` (header runs `__koopa_activate_koopa`),
`KOOPA_MINIMAL=1` (skip tools, keep only PATH), `KOOPA_SKIP=1` (abort activation),
`KOOPA_FORCE=1` (activate even in non-interactive session).

**Debugging tip:** `activate.ps1` removes `KOOPA_ACTIVATE` from the environment on
its last line after the header returns. An empty `$env:KOOPA_ACTIVATE` after activation
is normal — not evidence that activation failed. Check instead for the presence of
`_koopa_activate_starship` as a function, or count loaded functions:
```powershell
(Get-ChildItem Function: | Measure-Object).Count  # ~77 when fully activated
```

## Starship Integration

### Activation

`lang/powershell/functions/activate/activate-starship.ps1` — mtime-guarded cache:
```powershell
$starship = Join-Path $env:KOOPA_PREFIX 'bin/starship'
$cacheFile = Join-Path $env:XDG_CACHE_HOME 'koopa/shell-init/starship-powershell.ps1'
# Regenerate if binary is newer than cache:
& $starship init powershell | Set-Content $cacheFile
. $cacheFile
```
Cache: `~/.cache/koopa/shell-init/starship-powershell.ps1`.

The cached init is `starship init powershell --print-full-init`, which runs starship
as a **subprocess on every prompt render** and re-reads `~/.config/starship.toml`
each time. This means re-rendering `starship.toml` (e.g. via `chezmoi apply`) takes
effect on the **next prompt** — no re-sourcing or shell restart required.

### Starship Config

Shell-agnostic. Source: `opt/dotfiles/chezmoi/dot_config/starship.toml.tmpl`.
Dark/light palette selected at chezmoi-render time via `KOOPA_COLOR_MODE`.
PowerShell consumes it automatically — no per-shell toml needed.

The `[shell]` module in `starship.toml.tmpl` uses `powershell_indicator = '>'`,
matching PowerShell's own default prompt character (`PS C:\>`). Elvish also uses `>`
— that's fine, they're mutually exclusive in any session.

### header.ps1 Ordering (Critical)

`_koopa_activate_starship` (line 79) MUST run before `_koopa_activate_color_mode_sync`
(line 80). Starship's `--print-full-init` output defines `function global:prompt` inside
a `New-Module` block, which overwrites `$function:prompt` wholesale when executed via
`Invoke-Expression`. The color-mode-sync wrapper must therefore run *after* starship
has set `$function:prompt`, so it captures starship's scriptblock — not the built-in
default — as `$origPrompt`. If the order is reversed, the wrapper captures the default
prompt, and starship never renders.

## Color Mode Sync

### `activate-color-mode-sync.ps1`

Wraps the `prompt` function (capturing starship's prompt as `$origPrompt`). On every
prompt render it:

1. Detects current OS appearance via `_koopa_is_light_mode`.
2. If mode changed: updates `KOOPA_COLOR_MODE`, re-activates fzf/difftastic/dircolors
   (env-driven tools).
3. Checks the `color-mode-applied` marker (`~/.cache/koopa/color-mode-applied`).
   If stale AND `KOOPA_COLOR_MODE_SYNCING` is unset, backgrounds a `koopa configure
   user color-mode` via `Start-Process -NoNewWindow`:
   ```powershell
   $nullDev = if ($IsWindows) { 'NUL' } else { '/dev/null' }
   Start-Process -FilePath $koopaBin `
       -ArgumentList 'configure','user','color-mode' `
       -NoNewWindow `
       -RedirectStandardOutput $nullDev `
       -RedirectStandardError $nullDev `
       -ErrorAction SilentlyContinue | Out-Null
   ```
4. Calls `& $origPrompt` (starship).

The marker check is **outside** the `$newMode -ne $env:KOOPA_COLOR_MODE` block — so a
new shell whose env already matches but whose `color-mode-applied` marker is stale still
self-heals on its first prompt. This removes the need for a separate
`_koopa_activate_color_mode` function (bash/zsh have one; PowerShell doesn't need it).

### `KOOPA_COLOR_MODE_SYNCING` Recursion Guard

Set by `color_mode.py::main()` in the chezmoi apply subprocess env (line 154 of
`lang/python/src/koopa/configurers/color_mode.py`). Any koopa pwsh spawned during
the apply sees this and skips the background spawn — prevents flock deadlock / spawn
storm. Always check `$env:KOOPA_COLOR_MODE_SYNCING` before firing the background job.

### `_koopa_is_light_mode` — Per-Platform Detection

`lang/powershell/functions/core/is-light-mode.ps1`:

- **`$IsMacOS`** — reads `~/.cache/koopa/color-mode` cache first (set by OSC 11
  query or prior detection), then falls back to
  `defaults read -g AppleInterfaceStyle` (absent key = light mode).
- **`$IsWindows`** — reads registry:
  `HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme`
  (DWORD 1 = light, 0 = dark; `catch` → `$false`/dark as fallback).
- **tmux/screen** — reads `~/.cache/koopa/color-mode` cache.
- **Fallback** — `_koopa_terminal_is_light_background` (OSC 11 query).

### Python `os_appearance_mode()` — Windows Support

`lang/python/src/koopa/system.py::os_appearance_mode()` (line 100):

- Darwin: `defaults read -g AppleInterfaceStyle`.
- Linux: XDG portal → gsettings → cache file.
- **Windows**: `sys.platform == "win32"` guard (NOT `platform.system() == "Windows"`)
  with lazy `import winreg`. The `sys.platform` guard is required — pyright and ty
  use it for type narrowing so they resolve `winreg.*` attributes without ignore
  comments. `platform.system()` does not narrow:
  ```python
  if sys.platform == "win32":
      import winreg  # Windows-only stdlib; lazy import.
      try:
          with winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                              r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize") as key:
              value, _ = winreg.QueryValueEx(key, "AppsUseLightTheme")
          return "light" if value == 1 else "dark"
      except OSError:
          return "dark"
  ```

## `.GetNewClosure()` Is Required When Wrapping `$function:prompt`

PowerShell scriptblocks do **not** automatically close over locals from an enclosing
function. When `_koopa_activate_color_mode_sync` assigns a scriptblock to
`$function:prompt`, the scriptblock references `$origPrompt` by name. After the
function returns, its local scope is gone — `$origPrompt` resolves to `$null` at
every subsequent prompt render, causing `& $origPrompt` to fail with:

```
InvalidOperation: The expression after '&' in a pipeline element produced an object
that was not valid. It must result in a command name, a script block, or a CommandInfo
object.
```

**Fix:** call `.GetNewClosure()` on the scriptblock to bake the current value of
`$origPrompt` into the closure at install time:

```powershell
$origPrompt = $function:prompt
$function:prompt = {
    # ... wrapper logic ...
    & $origPrompt
}.GetNewClosure()   # ← required; without this, $origPrompt is $null at call time
```

This applies to any prompt-wrapper that captures `$function:prompt` inside a function.
The symptom is always `PS>` default prompt (starship never renders) plus an
`InvalidOperation` error when `$function:prompt` is invoked manually.

## Backgrounding Processes

No existing `Start-Process`/`Start-Job` idiom existed in `lang/powershell/` before the
color-mode sync work. Established pattern for non-blocking, no-console-flash background
invocation:

```powershell
$nullDev = if ($IsWindows) { 'NUL' } else { '/dev/null' }
Start-Process -FilePath $binaryPath `
    -ArgumentList 'arg1','arg2','arg3' `
    -NoNewWindow `
    -RedirectStandardOutput $nullDev `
    -RedirectStandardError $nullDev `
    -ErrorAction SilentlyContinue | Out-Null
```

`Start-Process` truly detaches (unlike `Start-Job`/`Start-ThreadJob` which tie into
the session job table and add per-prompt overhead). `-NoNewWindow` avoids a visible
console flash on Windows.

Note: some pwsh versions reject identical paths for `-RedirectStandardOutput` and
`-RedirectStandardError`. If that occurs, use two temp-file paths:
`[System.IO.Path]::GetTempFileName()`.

## Key File Paths

| File | Purpose |
|---|---|
| `lang/powershell/include/header.ps1` | Entry; dot-sources functions/, runs `__koopa_activate_koopa` |
| `lang/powershell/functions/activate/activate-starship.ps1` | Mtime-guarded starship init cache |
| `lang/powershell/functions/activate/activate-color-mode-sync.ps1` | Per-prompt flip detection + file re-render trigger |
| `lang/powershell/functions/core/is-light-mode.ps1` | OS appearance detection (macOS/Windows/tmux/OSC11) |
| `lang/powershell/functions/export/export-env.ps1` | Sets `KOOPA_COLOR_MODE` + writes color-mode cache at activation |
| `lang/python/src/koopa/system.py` | `os_appearance_mode()` — Python-side appearance detection inc. Windows |
| `opt/dotfiles/chezmoi/dot_config/powershell/Microsoft.PowerShell_profile.ps1.tmpl` | Chezmoi source for the profile |
| `~/.cache/koopa/shell-init/starship-powershell.ps1` | Cached `starship init powershell` output |
| `~/.cache/koopa/color-mode-applied` | Marker: last mode rendered by `koopa configure user color-mode` |
