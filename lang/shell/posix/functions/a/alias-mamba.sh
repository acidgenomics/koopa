#!/bin/sh

_koopa_alias_mamba() {
    # """
    # Mamba alias.
    # @note Updated 2023-03-27.
    # """
    _koopa_activate_conda
    _koopa_is_function 'mamba' || return 1
    mamba "$@"
}
