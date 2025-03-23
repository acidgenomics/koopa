#!/bin/sh

_koopa_user_id() {
    # """
    # Current user ID.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="$(id -u)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
