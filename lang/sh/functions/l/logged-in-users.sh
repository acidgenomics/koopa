#!/bin/sh

_koopa_logged_in_users() {
    # """
    # Logged in users.
    # @note Updated 2023-09-14.
    # """
    __kvar_string="$(who -q | head -n -1)"
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
