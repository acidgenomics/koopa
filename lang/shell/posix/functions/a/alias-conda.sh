#!/bin/sh

_koopa_alias_conda() {
    # """
    # Conda alias.
    # @note Updated 2023-03-27.
    # """
    _koopa_activate_conda
    _koopa_is_function 'conda' || return 1
    conda "$@"
}
