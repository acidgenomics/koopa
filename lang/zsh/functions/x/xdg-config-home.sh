#!/usr/bin/env zsh

_koopa_xdg_config_home() {
    local string
    string="${XDG_CONFIG_HOME:-}"
    if [[ -z "$string" ]]
    then
        string="${HOME:?}/.config"
    fi
    _koopa_print "$string"
    return 0
}
