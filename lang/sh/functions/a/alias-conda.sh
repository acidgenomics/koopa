#!/bin/sh

_koopa_alias_conda() {
    # """
    # Conda alias.
    # @note Updated 2023-06-29.
    # """
    # FIXME This is breaking inside of Docker image loop...
    unalias conda
    _koopa_activate_conda
    if ! _koopa_is_function 'conda'
    then
        _koopa_print 'conda is not active.'
        return 1
    fi
    type conda
    conda "$@"
}
