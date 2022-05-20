#!/bin/sh

# FIXME Consider moving this to Bash, or deleting.
koopa_lmod_prefix() {
    # """
    # Lmod prefix.
    # @note Updated 2021-01-20.
    # """
    koopa_print "$(koopa_opt_prefix)/lmod"
    return 0
}
