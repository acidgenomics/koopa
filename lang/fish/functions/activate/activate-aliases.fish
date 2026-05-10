function _koopa_activate_aliases
    # Activate aliases for fish shell.
    # @note Updated 2026-05-01.
    _koopa_is_interactive; or return 0
    set -l bin_prefix (_koopa_bin_prefix)
    set -l xdg_data_home (_koopa_xdg_data_home)
    # Navigation.
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    alias ......='cd ../../../../..'
    # Shortcuts.
    alias :q=exit
    alias c=clear
    alias e=exit
    alias g=git
    alias h=history
    alias q=exit
    # Koopa.
    alias k=koopa
    # ls.
    if test -x "$bin_prefix/eza"
        alias l="$bin_prefix/eza --classify --color=auto"
    else if test -x "$bin_prefix/gls"
        alias l='gls --color=auto -BFhp'
    else
        alias l='ls -BFhp'
    end
    alias l.='l -d .*'
    alias l1='ls -1'
    alias la='l -a'
    alias lh='l | head'
    alias ll='l -l'
    alias lt='l | tail'
    # Application-specific aliases.
    if test -x "$bin_prefix/black"
        alias black='black --line-length=79'
    end
    if test -x "$bin_prefix/chezmoi"
        alias cm=chezmoi
    end
    if test -x "$bin_prefix/fd"
        alias fd='fd --absolute-path --ignore-case --no-ignore'
    end
    if test -x "$bin_prefix/python3"
        alias python3-dev='PYTHONPATH=(pwd) python3'
    end
    if test -x /usr/local/bin/R; or test -x /usr/bin/R
        alias R='R --no-restore --no-save --quiet'
    end
    if test -x "$bin_prefix/zoxide"
        alias j=z
    end
    # User-defined aliases.
    if test -f "$HOME/.aliases"
        source "$HOME/.aliases"
    end
    if test -f "$HOME/.aliases-private"
        source "$HOME/.aliases-private"
    end
    if test -f "$HOME/.aliases-work"
        source "$HOME/.aliases-work"
    end
end
