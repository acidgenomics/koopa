#!/usr/bin/env bash

koopa_gsub() {
    # """
    # Global substitution.
    # @note Updated 2022-04-21.
    #
    # @usage koopa_gsub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > koopa_gsub --pattern='a' --replacement='' 'aabb' 'aacc'
    # # bb
    # # cc
    #
    # # koopa_gsub --pattern='/' --replacement='|' '/\|/\|'
    # # |\||\|
    # """
    koopa_sub --global "$@"
}
