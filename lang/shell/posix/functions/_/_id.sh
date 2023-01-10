#!/bin/sh

__koopa_id() {
    # """
    # Return ID string.
    # @note Updated 2022-02-25.
    # """
    local str
    str="$(id "$@")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}
