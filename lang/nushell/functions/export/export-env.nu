# Export environment variables for nushell.
# @note Updated 2026-05-01.
# @note Requires nushell 0.90+.
export def _koopa_export_env [] {
    # KOOPA_SHELL.
    $env.KOOPA_SHELL = (which nu | get 0.path)

    # KOOPA_CPU_COUNT.
    if (_koopa_is_macos) {
        $env.KOOPA_CPU_COUNT = (sysctl -n hw.ncpu | str trim)
    } else {
        $env.KOOPA_CPU_COUNT = (nproc | str trim)
    }

    # XDG base directories.
    if not ("XDG_CACHE_HOME" in $env) {
        $env.XDG_CACHE_HOME = $"($env.HOME)/.cache"
    }
    if not ("XDG_CONFIG_DIRS" in $env) {
        $env.XDG_CONFIG_DIRS = "/etc/xdg"
    }
    if not ("XDG_CONFIG_HOME" in $env) {
        $env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
    }
    if not ("XDG_DATA_DIRS" in $env) {
        $env.XDG_DATA_DIRS = "/usr/local/share:/usr/share"
    }
    if not ("XDG_DATA_HOME" in $env) {
        $env.XDG_DATA_HOME = $"($env.HOME)/.local/share"
    }
    if not ("XDG_STATE_HOME" in $env) {
        $env.XDG_STATE_HOME = $"($env.HOME)/.local/state"
    }

    # EDITOR / VISUAL.
    if not ("EDITOR" in $env) {
        let nvim = $"($env.KOOPA_PREFIX)/bin/nvim"
        if ($nvim | path exists) {
            $env.EDITOR = $nvim
        } else {
            $env.EDITOR = "vim"
        }
    }
    $env.VISUAL = $env.EDITOR

    # PAGER.
    if not ("PAGER" in $env) {
        let less = $"($env.KOOPA_PREFIX)/bin/less"
        if ($less | path exists) {
            $env.PAGER = $"($less) -R"
        }
    }

    # MANPAGER.
    if not ("MANPAGER" in $env) {
        let nvim = $"($env.KOOPA_PREFIX)/bin/nvim"
        if ($nvim | path exists) {
            $env.MANPAGER = $"($nvim) +Man!"
        }
    }

    # Color mode.
    if not ("KOOPA_COLOR_MODE" in $env) {
        $env.KOOPA_COLOR_MODE = "dark"
    }

    # GCC colors.
    if not ("GCC_COLORS" in $env) {
        $env.GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
    }

    # FZF.
    if not ("FZF_DEFAULT_OPTS" in $env) {
        $env.FZF_DEFAULT_OPTS = "--border --color bw --multi"
    }
}
