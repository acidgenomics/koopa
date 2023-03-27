#!/bin/sh

_koopa_alias_z() {
    # """
    # Zoxide alias.
    # @note Updated 2023-03-27.
    # """
    _koopa_activate_zoxide
    _koopa_is_function 'z' || return 1
    z "$@"
}
