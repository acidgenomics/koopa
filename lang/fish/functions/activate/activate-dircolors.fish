function _koopa_activate_dircolors
    # Activate dircolors (LS_COLORS) for fish shell.
    # @note Updated 2026-06-13.
    set -l dircolors "$KOOPA_PREFIX/bin/gdircolors"
    if not test -x "$dircolors"
        return 0
    end
    set -l prefix "$XDG_CONFIG_HOME/dircolors"
    if not test -d "$prefix"
        return 0
    end
    set -l conf_file "$prefix/dircolors-$KOOPA_COLOR_MODE"
    if not test -f "$conf_file"
        return 0
    end
    # gdircolors only emits sh/csh; extract the LS_COLORS value directly.
    set -l line ("$dircolors" --sh "$conf_file")[1]
    set -gx LS_COLORS (string replace -r "^LS_COLORS='(.*)';\$" '$1' -- "$line")
    alias gdir='gdir --color=auto'
    alias gegrep='gegrep --color=auto'
    alias gfgrep='gfgrep --color=auto'
    alias ggrep='ggrep --color=auto'
    alias gls='gls --color=auto'
    alias gvdir='gvdir --color=auto'
end
