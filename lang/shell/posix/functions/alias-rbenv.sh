#!/bin/sh

koopa_alias_rbenv() {
    # """
    # rbenv alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'rbenv' && unalias 'rbenv'
    koopa_activate_rbenv
    rbenv "$@"
}
