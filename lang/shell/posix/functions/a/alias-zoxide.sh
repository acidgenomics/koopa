#!/bin/sh

_koopa_alias_zoxide() {
    # """
    # Zoxide alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'z' && unalias 'z'
    _koopa_activate_zoxide
    z "$@"
}
