#!/bin/sh

_koopa_group_name() {
    # """
    # Current user's default group name.
    # @note Updated 2023-03-26.
    # """
    __kvar_string="$(id -gn)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
