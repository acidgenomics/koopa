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
    if ($IsWindows) {
        try {
            $v = Get-ItemPropertyValue `
                -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' `
                -Name 'AppsUseLightTheme'
            return $v -eq 1
        } catch {
            return $false
        }
    }
    if ($env:TMUX -or $env:TERM -like 'screen*' -or $env:TERM -like 'tmux*') {
        $cacheFile = Join-Path $HOME '.cache/koopa/color-mode'
        if (Test-Path $cacheFile) {
            return (Get-Content $cacheFile -First 1).Trim() -eq 'light'
        }
        return $false
    }
    if ($env:SSH_CONNECTION -or $env:SSH_TTY) {
        $cacheFile = Join-Path $HOME '.cache/koopa/color-mode'
        if (Test-Path $cacheFile) {
            return (Get-Content $cacheFile -First 1).Trim() -eq 'light'
        }
        return $false
    }
    return (_koopa_terminal_is_light_background)
}
