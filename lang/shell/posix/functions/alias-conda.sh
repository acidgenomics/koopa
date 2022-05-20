#!/bin/sh

koopa_alias_conda() {
    # """
    # Conda alias.
    # @note Updated 2022-02-02.
    # """
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_activate_conda
    conda "$@"
}
