#!/bin/sh

_koopa_group() {
    # """
    # Current user's default group.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="$(id -gn)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
