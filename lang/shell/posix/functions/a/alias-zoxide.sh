#!/bin/sh

koopa_alias_zoxide() {
    # """
    # Zoxide alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'z' && unalias 'z'
    koopa_activate_zoxide
    z "$@"
}
