#!/usr/bin/env bash

# FIXME REORGANIZE THIS SCRIPT?

# FIXME THIS NEEDS TO EXCLUDE 'APP' and 'OPT' BETTER.
koopa::list() { # {{{1
    # """
    # List koopa programs available in PATH.
    # @note Updated 2020-12-31.
    # """
    koopa::rscript_vanilla 'list'
    return 0
}
