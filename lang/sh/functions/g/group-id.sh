#!/bin/sh

_koopa_group_id() {
    # """
    # Current user's default group ID.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="$(id -g)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
