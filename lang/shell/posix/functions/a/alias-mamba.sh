#!/bin/sh

_koopa_alias_mamba() {
    # """
    # Mamba alias.
    # @note Updated 2023-05-11.
    # """
    _koopa_activate_conda
    if ! _koopa_is_function 'mamba'
    then
        _koopa_print 'mamba is not active.'
        return 1
    fi
    mamba "$@"
}
