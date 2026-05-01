#!/usr/bin/env bash

_koopa_xdg_config_dirs() {
    local string
    string="${XDG_CONFIG_DIRS:-}"
    if [[ -z "$string" ]]
    then
        string='/etc/xdg'
    fi
    _koopa_print "$string"
    return 0
}
