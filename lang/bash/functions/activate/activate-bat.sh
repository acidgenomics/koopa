#!/usr/bin/env bash

_koopa_activate_bat() {
    [[ -x "$(_koopa_bin_prefix)/bat" ]] || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/bat"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conf_file
    conf_file="${prefix}/config-$(_koopa_color_mode)"
    if [[ ! -f "$conf_file" ]]
    then
        return 0
    fi
    export BAT_CONFIG_PATH="$conf_file"
    return 0
}
