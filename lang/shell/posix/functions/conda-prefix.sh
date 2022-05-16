#!/bin/sh

koopa_conda_prefix() {
    # """
    # Conda prefix.
    # @note Updated 2021-05-25.
    # @seealso conda info --base
    # """
    koopa_print "$(koopa_opt_prefix)/conda"
    return 0
}
