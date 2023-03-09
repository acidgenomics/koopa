#!/bin/sh

_koopa_xdg_cache_home() {
    # """
    # XDG cache home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    _koopa_print "$x"
    return 0
}
