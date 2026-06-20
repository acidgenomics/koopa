# Activate color mode sync hook.
# @note Updated 2026-06-14.
function _koopa_activate_color_mode_sync {
    $origPrompt = $function:prompt
    $function:prompt = {
        $newMode = if (_koopa_is_light_mode) { 'light' } else { 'dark' }
        if ($newMode -ne $env:KOOPA_COLOR_MODE) {
            $env:KOOPA_COLOR_MODE = $newMode
            [Console]::Error.WriteLine(
                "Terminal appearance changed to $newMode mode. Updating shell colors."
            )
            Remove-Item Env:FZF_DEFAULT_OPTS -ErrorAction SilentlyContinue
            _koopa_activate_fzf
            _koopa_activate_difftastic
            _koopa_activate_dircolors
        }
        # File-driven re-render trigger (starship/bat/delta toml). Backgrounded,
        # marker + sentinel guarded; mirrors bash _koopa_activate_color_mode.
        if (-not $env:KOOPA_COLOR_MODE_SYNCING) {
            $appliedFile = Join-Path $HOME '.cache/koopa/color-mode-applied'
            $applied = if (Test-Path $appliedFile) {
                (Get-Content $appliedFile -First 1).Trim()
            } else { '' }
            if ($applied -ne $newMode) {
                $koopaBin = Join-Path $env:KOOPA_PREFIX 'bin/koopa'
                if (Test-Path $koopaBin) {
                    $nullDev = if ($IsWindows) { 'NUL' } else { '/dev/null' }
                    Start-Process -FilePath $koopaBin `
                        -ArgumentList 'configure', 'user', 'color-mode' `
                        -NoNewWindow `
                        -RedirectStandardOutput $nullDev `
                        -RedirectStandardError $nullDev `
                        -ErrorAction SilentlyContinue | Out-Null
                }
            }
        }
        & $origPrompt
    }.GetNewClosure()
}
