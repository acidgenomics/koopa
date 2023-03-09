#!/bin/sh

_koopa_alias_conda() {
    # """
    # Conda alias.
    # @note Updated 2022-02-02.
    # """
    _koopa_is_alias 'conda' && unalias 'conda'
    _koopa_activate_conda
    conda "$@"
}
