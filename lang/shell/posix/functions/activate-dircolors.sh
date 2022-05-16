#!/bin/sh

koopa_activate_dircolors() {
    # """
    # Activate directory colors.
    # @note Updated 2022-05-12.
    #
    # This will set the 'LS_COLORS' environment variable.
    #
    # Ensure this follows 'koopa_activate_color_mode'.
    # """
    [ -n "${SHELL:-}" ] || return 0
    local dircolors
    dircolors="$(koopa_bin_prefix)/dircolors"
    [ -x "$dircolors" ] || return 0
    local color_mode config_prefix dircolors_file
    config_prefix="$(koopa_xdg_config_home)/dircolors"
    color_mode="$(koopa_color_mode)"
    dircolors_file="${config_prefix}/dircolors-${color_mode}"
    [ -f "$dircolors_file" ] || return 0
    eval "$("$dircolors" "$dircolors_file")"
    alias dir='dir --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias vdir='vdir --color=auto'
    return 0
}
