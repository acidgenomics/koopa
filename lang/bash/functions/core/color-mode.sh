#!/usr/bin/env bash

_koopa_color_mode() {
    local string
    string="${KOOPA_COLOR_MODE:-}"
    if [[ -z "$string" ]]
    then
        if _koopa_is_macos
        then
            if _koopa_macos_is_dark_mode
            then
                string='dark'
            else
                string='light'
            fi
        else
            string='dark'
        fi
    fi
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
