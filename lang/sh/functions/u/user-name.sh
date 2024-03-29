#!/bin/sh

_koopa_user_name() {
    # """
    # Current user name.
    # @note Updated 2023-03-26.
    #
    # Alternatively, can use 'whoami' here.
    # """
    __kvar_string="$(id -un)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
