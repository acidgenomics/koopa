#!/usr/bin/env zsh

_koopa_activate_ripgrep() {
    [[ -x "$(_koopa_bin_prefix)/rg" ]] || return 0
    local config_file
    config_file="${XDG_CONFIG_HOME:?}/ripgrep/config"
    if [[ -f "$config_file" ]]
    then
        RIPGREP_CONFIG_PATH="$config_file"
        export RIPGREP_CONFIG_PATH
    fi
    return 0
}
