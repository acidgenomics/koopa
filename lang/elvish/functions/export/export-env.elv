# Export environment variables for Elvish.
# @note Updated 2026-05-01.
use platform

fn export-env {
    # HOME.
    if (not (has-env HOME)) {
        set-env HOME ~
    }

    # KOOPA_SHELL.
    set-env KOOPA_SHELL (search-external elvish)

    if (not (has-env SHELL)) {
        set-env SHELL $E:KOOPA_SHELL
    }

    # KOOPA_CPU_COUNT.
    if (eq $platform:os 'darwin') {
        set-env KOOPA_CPU_COUNT (str:trim-space (sysctl -n hw.ncpu 2>/dev/null))
    } else {
        try {
            set-env KOOPA_CPU_COUNT (str:trim-space (nproc 2>/dev/null))
        } catch {
            set-env KOOPA_CPU_COUNT '1'
        }
    }

    # XDG base directories.
    if (not (has-env XDG_CACHE_HOME)) {
        set-env XDG_CACHE_HOME $E:HOME'/.cache'
    }
    if (not (has-env XDG_CONFIG_DIRS)) {
        set-env XDG_CONFIG_DIRS '/etc/xdg'
    }
    if (not (has-env XDG_CONFIG_HOME)) {
        set-env XDG_CONFIG_HOME $E:HOME'/.config'
    }
    if (not (has-env XDG_DATA_DIRS)) {
        set-env XDG_DATA_DIRS '/usr/local/share:/usr/share'
    }
    if (not (has-env XDG_DATA_HOME)) {
        set-env XDG_DATA_HOME $E:HOME'/.local/share'
    }
    if (not (has-env XDG_STATE_HOME)) {
        set-env XDG_STATE_HOME $E:HOME'/.local/state'
    }

    # EDITOR / VISUAL.
    if (not (has-env EDITOR)) {
        var nvim = $E:KOOPA_PREFIX'/bin/nvim'
        if (path:is-regular &follow-symlink $nvim) {
            set-env EDITOR $nvim
        } else {
            set-env EDITOR vim
        }
    }
    set-env VISUAL $E:EDITOR

    # PAGER.
    if (not (has-env PAGER)) {
        var less = $E:KOOPA_PREFIX'/bin/less'
        if (path:is-regular &follow-symlink $less) {
            set-env PAGER $less' -R'
        }
    }

    # MANPAGER.
    if (not (has-env MANPAGER)) {
        var nvim = $E:KOOPA_PREFIX'/bin/nvim'
        if (path:is-regular &follow-symlink $nvim) {
            set-env MANPAGER $nvim' +Man!'
        }
    }

    # GnuPG.
    if (not (has-env GPG_TTY)) {
        try {
            set-env GPG_TTY (tty 2>/dev/null)
        } catch { }
    }

    # Color mode.
    if (not (has-env KOOPA_COLOR_MODE)) {
        set-env KOOPA_COLOR_MODE dark
    }

    # GCC colors.
    if (not (has-env GCC_COLORS)) {
        set-env GCC_COLORS 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    }
}
