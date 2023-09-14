#!/bin/sh

_koopa_logged_in_user_count() {
    # """
    # Number of logged in users.
    # @note Updated 2023-09-14.
    # """
    __kvar_string="$(_koopa_logged_in_users | wc -l)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
