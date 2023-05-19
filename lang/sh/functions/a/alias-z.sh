#!/bin/sh

_koopa_alias_z() {
    # """
    # Zoxide alias.
    # @note Updated 2023-05-11.
    # """
    _koopa_activate_zoxide
    if ! _koopa_is_function '__zoxide_z'
    then
        _koopa_print 'zoxide is not active.'
        return 1
    fi
    __zoxide_z "$@"
}
