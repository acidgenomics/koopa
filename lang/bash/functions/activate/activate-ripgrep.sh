#!/usr/bin/env bash

_koopa_activate_ripgrep() {
    [[ -x "$(_koopa_bin_prefix)/rg" ]] || return 0
    local config_file
    config_file="$(_koopa_xdg_config_home)/ripgrep/config"
    if [[ -f "$config_file" ]]
    then
        RIPGREP_CONFIG_PATH="$config_file"
        export RIPGREP_CONFIG_PATH
    fi
    return 0
}
