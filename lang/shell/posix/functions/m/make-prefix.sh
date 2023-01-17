#!/bin/sh

koopa_make_prefix() {
    # """
    # Return the installation prefix to use.
    # @note Updated 2023-01-10.
    # """
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif koopa_is_user_install
    then
        prefix="$(koopa_xdg_local_home)"
    else
        prefix='/usr/local'
    fi
    koopa_print "$prefix"
    return 0
}