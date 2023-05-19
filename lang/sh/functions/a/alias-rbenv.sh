#!/bin/sh

_koopa_alias_rbenv() {
    # """
    # rbenv alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'rbenv' && unalias 'rbenv'
    _koopa_activate_rbenv
    rbenv "$@"
}
