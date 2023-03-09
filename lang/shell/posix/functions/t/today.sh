#!/bin/sh

_koopa_today() {
    # """
    # Today string.
    # @note Updated 2021-05-26.
    # """
    local str
    str="$(date '+%Y-%m-%d')"
    [ -n "$str" ] || return 1
    _koopa_print "$str"
    return 0
}
