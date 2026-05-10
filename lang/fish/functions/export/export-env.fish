function _koopa_export_env
    # Export environment variables for fish shell.
    # @note Updated 2026-05-01.

    # HOME.
    if not set -q HOME
        set -gx HOME (pwd)
    end

    # KOOPA_SHELL.
    set -gx KOOPA_SHELL (status fish-path)
    if not set -q SHELL
        set -gx SHELL "$KOOPA_SHELL"
    end

    # KOOPA_CPU_COUNT.
    if _koopa_is_macos
        set -gx KOOPA_CPU_COUNT (sysctl -n hw.ncpu 2>/dev/null; or echo 1)
    else
        set -gx KOOPA_CPU_COUNT (nproc 2>/dev/null; or echo 1)
    end

    # XDG base directories.
    if not set -q XDG_CACHE_HOME
        set -gx XDG_CACHE_HOME "$HOME/.cache"
    end
    if not set -q XDG_CONFIG_DIRS
        set -gx XDG_CONFIG_DIRS /etc/xdg
    end
    if not set -q XDG_CONFIG_HOME
        set -gx XDG_CONFIG_HOME "$HOME/.config"
    end
    if not set -q XDG_DATA_DIRS
        set -gx XDG_DATA_DIRS /usr/local/share:/usr/share
    end
    if not set -q XDG_DATA_HOME
        set -gx XDG_DATA_HOME "$HOME/.local/share"
    end
    if not set -q XDG_STATE_HOME
        set -gx XDG_STATE_HOME "$HOME/.local/state"
    end

    # EDITOR / VISUAL.
    if not set -q EDITOR
        set -l nvim (_koopa_bin_prefix)/nvim
        if test -x "$nvim"
            set -gx EDITOR "$nvim"
        else
            set -gx EDITOR vim
        end
    end
    set -gx VISUAL "$EDITOR"

    # PAGER.
    if not set -q PAGER
        set -l less (_koopa_bin_prefix)/less
        if test -x "$less"
            set -gx PAGER "$less -R"
        end
    end

    # MANPAGER.
    if not set -q MANPAGER
        set -l nvim (_koopa_bin_prefix)/nvim
        if test -x "$nvim"
            set -gx MANPAGER "$nvim +Man!"
        end
    end

    # GnuPG.
    if not set -q GPG_TTY
        if isatty
            set -gx GPG_TTY (tty)
        end
    end

    # History.
    # Fish manages its own history, but set HISTFILE for compatibility.
    if not set -q HISTFILE
        set -gx HISTFILE "$HOME/.fish_history"
    end

    # Color mode.
    if not set -q KOOPA_COLOR_MODE
        set -gx KOOPA_COLOR_MODE dark
    end

    # GCC colors.
    if not set -q GCC_COLORS
        set -gx GCC_COLORS 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    end
end
