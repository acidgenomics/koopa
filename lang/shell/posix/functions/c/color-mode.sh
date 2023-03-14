#!/bin/sh

_koopa_color_mode() {
    # """
    # Color mode.
    # @note Updated 2023-03-11.
    # """
    __kvar_string="${KOOPA_COLOR_MODE:-}"
    if [ -z "$__kvar_string" ]
    then
        if _koopa_is_macos
        then
            if _koopa_macos_is_dark_mode
            then
                __kvar_string='dark'
            else
                __kvar_string='light'
            fi
        else
            __kvar_string='dark'
        fi
    fi
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
