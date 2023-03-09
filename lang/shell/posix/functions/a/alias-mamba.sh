#!/bin/sh

_koopa_alias_mamba() {
    # """
    # Mamba alias.
    # @note Updated 2022-01-21.
    # """
    _koopa_is_alias 'conda' && unalias 'conda'
    _koopa_is_alias 'mamba' && unalias 'mamba'
    _koopa_activate_conda
    mamba "$@"
}
