# Activate color mode sync hook.
# @note Updated 2026-05-31.
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
        }
        & $origPrompt
    }
}
