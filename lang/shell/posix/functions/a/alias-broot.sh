#!/bin/sh

_koopa_alias_broot() {
    # """
    # Broot 'br' alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'br' && unalias 'br'
    _koopa_activate_broot
    br "$@"
}
