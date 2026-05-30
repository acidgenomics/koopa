#!/usr/bin/env zsh

_koopa_color_mode() {
    local string
    string="${KOOPA_COLOR_MODE:-}"
    if [[ -z "$string" ]]
    then
        if _koopa_is_interactive && _koopa_is_light_mode
        then
            string='light'
        else
            string='dark'
        fi
    fi
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
