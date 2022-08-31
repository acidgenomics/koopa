#!/bin/sh

koopa_alias_asdf() {
    # """
    # asdf alias.
    # @note Updated 2022-08-31.
    # """
    koopa_is_alias 'asdf' && unalias 'asdf'
    koopa_activate_asdf
    asdf "$@"
}
