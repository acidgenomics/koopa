#!/bin/sh

_koopa_xdg_cache_home() {
    # """
    # XDG cache home.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="${XDG_CACHE_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="${HOME:?}/.cache"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
