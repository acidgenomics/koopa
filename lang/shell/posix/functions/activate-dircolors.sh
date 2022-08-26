#!/bin/sh

koopa_activate_dircolors() {
    # """
    # Activate directory colors.
    # @note Updated 2022-08-26.
    #
    # This will set the 'LS_COLORS' environment variable.
    #
    # Ensure this follows 'koopa_activate_color_mode'.
    # """
    [ -n "${SHELL:-}" ] || return 0
    local dircolors
    dircolors="$(koopa_bin_prefix)/gdircolors"
    [ -x "$dircolors" ] || return 0
    local color_mode config_prefix dircolors_file
    config_prefix="$(koopa_xdg_config_home)/dircolors"
    color_mode="$(koopa_color_mode)"
    dircolors_file="${config_prefix}/dircolors-${color_mode}"
    [ -f "$dircolors_file" ] || return 0
    eval "$("$dircolors" "$dircolors_file")"
    alias gdir='gdir --color=auto'
    alias gegrep='gegrep --color=auto'
    alias gfgrep='gfgrep --color=auto'
    alias ggrep='ggrep --color=auto'
    alias gls='gls --color=auto'
    alias gvdir='gvdir --color=auto'
    return 0
}
