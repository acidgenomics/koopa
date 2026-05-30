#!/usr/bin/env bash

_koopa_is_light_mode() {
    if [[ "$OSTYPE" == darwin* ]]
    then
        [[ "$(/usr/bin/defaults read -g 'AppleInterfaceStyle' 2>/dev/null)" != 'Dark' ]]
    else
        _koopa_terminal_is_light_background
    fi
}
