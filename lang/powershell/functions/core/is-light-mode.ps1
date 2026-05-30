function _koopa_is_light_mode {
    if ($IsMacOS) {
        $cacheFile = Join-Path $HOME '.cache/koopa/color-mode'
        if (Test-Path $cacheFile) {
            $mode = (Get-Content $cacheFile -First 1).Trim()
            return $mode -eq 'light'
        }
        $style = (& /usr/bin/defaults read -g AppleInterfaceStyle 2>$null) -join ''
        return $style -ne 'Dark'
    }
    return (_koopa_terminal_is_light_background)
}
