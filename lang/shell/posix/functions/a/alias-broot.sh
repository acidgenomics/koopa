#!/bin/sh

koopa_alias_broot() {
    # """
    # Broot 'br' alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'br' && unalias 'br'
    koopa_activate_broot
    br "$@"
}
