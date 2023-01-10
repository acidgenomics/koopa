#!/bin/sh

koopa_alias_pyenv() {
    # """
    # pyenv alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'pyenv' && unalias 'pyenv'
    koopa_activate_pyenv
    pyenv "$@"
}
