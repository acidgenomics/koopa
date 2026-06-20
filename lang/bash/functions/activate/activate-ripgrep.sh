#!/usr/bin/env bash

_koopa_activate_ripgrep() {
    [[ -x "${KOOPA_PREFIX:?}/bin/rg" ]] || return 0
    local config_file
    config_file="${XDG_CONFIG_HOME:?}/ripgrep/config"
    if [[ -f "$config_file" ]]
    then
        RIPGREP_CONFIG_PATH="$config_file"
        export RIPGREP_CONFIG_PATH
    fi
    return 0
}
