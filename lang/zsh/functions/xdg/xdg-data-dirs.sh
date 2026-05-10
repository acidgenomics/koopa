#!/usr/bin/env zsh

_koopa_xdg_data_dirs() {
    local string
    string="${XDG_DATA_DIRS:-}"
    if [[ -z "$string" ]]
    then
        string='/usr/local/share:/usr/share'
    fi
    _koopa_print "$string"
    return 0
}
