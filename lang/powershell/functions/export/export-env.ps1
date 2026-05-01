# Export environment variables for PowerShell.
# @note Updated 2026-05-01.
function _koopa_export_env {
    # HOME.
    if (-not $env:HOME) {
        $env:HOME = $HOME
    }

    # KOOPA_SHELL.
    $env:KOOPA_SHELL = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    if (-not $env:KOOPA_SHELL) {
        $env:KOOPA_SHELL = (Get-Command powershell -ErrorAction SilentlyContinue).Source
    }
    if (-not $env:SHELL) {
        $env:SHELL = $env:KOOPA_SHELL
    }

    # KOOPA_CPU_COUNT.
    if (_koopa_is_macos) {
        $env:KOOPA_CPU_COUNT = (sysctl -n hw.ncpu 2>$null)
    } else {
        $env:KOOPA_CPU_COUNT = (nproc 2>$null)
    }
    if (-not $env:KOOPA_CPU_COUNT) {
        $env:KOOPA_CPU_COUNT = '1'
    }

    # XDG base directories.
    if (-not $env:XDG_CACHE_HOME) {
        $env:XDG_CACHE_HOME = Join-Path $HOME '.cache'
    }
    if (-not $env:XDG_CONFIG_DIRS) {
        $env:XDG_CONFIG_DIRS = '/etc/xdg'
    }
    if (-not $env:XDG_CONFIG_HOME) {
        $env:XDG_CONFIG_HOME = Join-Path $HOME '.config'
    }
    if (-not $env:XDG_DATA_DIRS) {
        $env:XDG_DATA_DIRS = '/usr/local/share:/usr/share'
    }
    if (-not $env:XDG_DATA_HOME) {
        $env:XDG_DATA_HOME = Join-Path $HOME '.local/share'
    }
    if (-not $env:XDG_STATE_HOME) {
        $env:XDG_STATE_HOME = Join-Path $HOME '.local/state'
    }

    # EDITOR / VISUAL.
    if (-not $env:EDITOR) {
        $nvim = Join-Path $env:KOOPA_PREFIX 'bin/nvim'
        if (Test-Path $nvim) {
            $env:EDITOR = $nvim
        } else {
            $env:EDITOR = 'vim'
        }
    }
    $env:VISUAL = $env:EDITOR

    # PAGER.
    if (-not $env:PAGER) {
        $less = Join-Path $env:KOOPA_PREFIX 'bin/less'
        if (Test-Path $less) {
            $env:PAGER = "$less -R"
        }
    }

    # MANPAGER.
    if (-not $env:MANPAGER) {
        $nvim = Join-Path $env:KOOPA_PREFIX 'bin/nvim'
        if (Test-Path $nvim) {
            $env:MANPAGER = "$nvim +Man!"
        }
    }

    # GnuPG.
    if (-not $env:GPG_TTY) {
        try {
            $env:GPG_TTY = (tty 2>$null)
        } catch {}
    }

    # Color mode.
    if (-not $env:KOOPA_COLOR_MODE) {
        $env:KOOPA_COLOR_MODE = 'dark'
    }

    # GCC colors.
    if (-not $env:GCC_COLORS) {
        $env:GCC_COLORS = 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    }
}
