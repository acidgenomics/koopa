#!/bin/sh

_koopa_logged_in_users() {
    # """
    # Logged in users.
    # @note Updated 2023-09-14.
    #
    # Usage of 'who -q' is problematic when the same user is connected via
    # multiple SSH sessions. Need to filter this out.
    #
    # @seealso
    # - man who
    # - man w
    # """
    __kvar_string="$( \
        who -q \
        | awk 'NR > 1 { print prev } { prev = $0 }' \
        | tr ' ' '\n' \
        | sort \
        | uniq \
    )"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
