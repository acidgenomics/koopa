#!/usr/bin/env bash

koopa_make_prefix() {
    # """
    # Return the installation prefix to use.
    # @note Updated 2023-03-12.
    # """
    local prefix
    prefix="${KOOPA_MAKE_PREFIX:-}"
    if [[ -z "$prefix" ]]
    then
        if koopa_is_user_install
        then
            prefix="$(koopa_xdg_local_home)"
        else
            prefix='/usr/local'
        fi
    fi
    [[ -n "$prefix" ]] || return 1
    koopa_print "$prefix"
    return 0
}
