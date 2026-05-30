#!/usr/bin/env bash

_koopa_is_light_mode() {
    if [[ "$OSTYPE" == darwin* ]]
    then
        local cache_file="${HOME:?}/.cache/koopa/color-mode"
        if [[ -f "$cache_file" ]]
        then
            [[ "$(<"$cache_file")" == 'light' ]]
        else
            [[ "$(/usr/bin/defaults read -g 'AppleInterfaceStyle' 2>/dev/null)" != 'Dark' ]]
        fi
    else
        _koopa_terminal_is_light_background
    fi
}
