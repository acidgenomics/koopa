#!/bin/sh

koopa_alias_mamba() {
    # """
    # Mamba alias.
    # @note Updated 2022-01-21.
    # """
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_is_alias 'mamba' && unalias 'mamba'
    koopa_activate_conda
    mamba "$@"
}
