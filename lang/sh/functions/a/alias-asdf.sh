#!/bin/sh

_koopa_alias_asdf() {
    # """
    # asdf alias.
    # @note Updated 2022-08-31.
    # """
    _koopa_is_alias 'asdf' && unalias 'asdf'
    _koopa_activate_asdf
    asdf "$@"
}
