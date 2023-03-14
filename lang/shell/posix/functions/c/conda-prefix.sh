#!/bin/sh

_koopa_conda_prefix() {
    # """
    # Conda prefix.
    # @note Updated 2021-05-25.
    # @seealso conda info --base
    # """
    _koopa_print "$(_koopa_opt_prefix)/conda"
    return 0
}
