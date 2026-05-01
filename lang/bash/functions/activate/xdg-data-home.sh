#!/usr/bin/env bash

_koopa_xdg_data_home() {
    local string
    string="${XDG_DATA_HOME:-}"
    if [[ -z "$string" ]]
    then
        string="${HOME:?}/.local/share"
    fi
    _koopa_print "$string"
    return 0
}
