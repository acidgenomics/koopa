#!/usr/bin/env bash

_koopa_gsub() {
    # """
    # Global substitution.
    # @note Updated 2022-04-21.
    #
    # @usage _koopa_gsub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > _koopa_gsub --pattern='a' --replacement='' 'aabb' 'aacc'
    # # bb
    # # cc
    #
    # # _koopa_gsub --pattern='/' --replacement='|' '/\|/\|'
    # # |\||\|
    # """
    _koopa_sub --global "$@"
}
