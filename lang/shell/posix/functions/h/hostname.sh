#!/bin/sh

_koopa_hostname() {
    # """
    # Host name.
    # @note Updated 2022-01-21.
    # """
    local x
    x="$(uname -n)"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}
