#!/usr/bin/env zsh

_koopa_activate_bat() {
    [[ -x "$(_koopa_bin_prefix)/bat" ]] || return 0
    local prefix
    prefix="${XDG_CONFIG_HOME:?}/bat"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conf_file
    conf_file="${prefix}/config"
    if [[ ! -f "$conf_file" ]]
    then
        return 0
    fi
    export BAT_CONFIG_PATH="$conf_file"
    return 0
}
