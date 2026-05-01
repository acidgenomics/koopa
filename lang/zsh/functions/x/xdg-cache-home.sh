#!/usr/bin/env zsh

_koopa_xdg_cache_home() {
    local string
    string="${XDG_CACHE_HOME:-}"
    if [[ -z "$string" ]]
    then
        string="${HOME:?}/.cache"
    fi
    _koopa_print "$string"
    return 0
}
