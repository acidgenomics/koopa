#!/bin/sh

_koopa_activate_dircolors() {
    # """
    # Activate directory colors.
    # @note Updated 2023-03-09.
    #
    # This will set the 'LS_COLORS' environment variable.
    #
    # Ensure this follows '_koopa_activate_color_mode'.
    # """
    [ -n "${SHELL:-}" ] || return 0
    __kvar_dircolors="$(_koopa_bin_prefix)/gdircolors"
    if [ ! -x "$__kvar_dircolors" ]
    then
        unset -v __kvar_dircolors
        return 0
    fi
    __kvar_prefix="$(_koopa_xdg_config_home)/dircolors"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_dircolors __kvar_prefix
        return 0
    fi
    __kvar_conf_file="${__kvar_prefix}/dircolors-$(_koopa_color_mode)"
    if [ ! -f "$__kvar_conf_file" ]
    then
        unset -v \
            __kvar_conf_file \
            __kvar_dircolors
        return 0
    fi
    eval "$("$__kvar_dircolors" "$__kvar_conf_file")"
    alias gdir='gdir --color=auto'
    alias gegrep='gegrep --color=auto'
    alias gfgrep='gfgrep --color=auto'
    alias ggrep='ggrep --color=auto'
    alias gls='gls --color=auto'
    alias gvdir='gvdir --color=auto'
    unset -v \
        __kvar_conf_file \
        __kvar_dircolors
    return 0
}
