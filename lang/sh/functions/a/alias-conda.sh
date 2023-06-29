#!/bin/sh

# FIXME This is creating an infinite loop inside of Docker bash.
# Can reprex with our conda image...
# need to rethink.

_koopa_alias_conda() {
    # """
    # Conda alias.
    # @note Updated 2023-05-12.
    # """
    _koopa_activate_conda
    if ! _koopa_is_function 'conda'
    then
        _koopa_print 'conda is not active.'
        return 1
    fi
    conda "$@"
}
