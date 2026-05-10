#!/usr/bin/env bash

_koopa_activate_dircolors() {
    [[ -n "${SHELL:-}" ]] || return 0
    local dircolors
    dircolors="$(_koopa_bin_prefix)/gdircolors"
    if [[ ! -x "$dircolors" ]]
    then
        return 0
    fi
    local prefix
    prefix="$(_koopa_xdg_config_home)/dircolors"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conf_file
    conf_file="${prefix}/dircolors-$(_koopa_color_mode)"
    if [[ ! -f "$conf_file" ]]
    then
        return 0
    fi
    eval "$("$dircolors" "$conf_file")"
    alias gdir='gdir --color=auto'
    alias gegrep='gegrep --color=auto'
    alias gfgrep='gfgrep --color=auto'
    alias ggrep='ggrep --color=auto'
    alias gls='gls --color=auto'
    alias gvdir='gvdir --color=auto'
    return 0
}
