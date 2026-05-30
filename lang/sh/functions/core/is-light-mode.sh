#!/bin/sh

_koopa_is_light_mode() {
    if _koopa_is_macos
    then
        __kvar_cache_file="${HOME:?}/.cache/koopa/color-mode"
        if [ -f "$__kvar_cache_file" ]
        then
            read -r __kvar_mode < "$__kvar_cache_file" 2>/dev/null || __kvar_mode=''
            [ "$__kvar_mode" = 'light' ]
            __kvar_result=$?
            unset -v __kvar_cache_file __kvar_mode
            return "$__kvar_result"
        fi
        unset -v __kvar_cache_file
        [ "$(/usr/bin/defaults read -g 'AppleInterfaceStyle' 2>/dev/null)" != 'Dark' ]
    else
        _koopa_terminal_is_light_background
    fi
}
