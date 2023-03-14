#!/bin/sh

_koopa_alias_pyenv() {
    # """
    # pyenv alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'pyenv' && unalias 'pyenv'
    _koopa_activate_pyenv
    pyenv "$@"
}
