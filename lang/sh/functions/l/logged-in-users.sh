#!/bin/sh

_koopa_logged_in_users() {
    # """
    # Logged in users.
    # @note Updated 2023-09-14.
    #
    # Can use 'head -n -1' only with GNU coreutils.
    # Usage of 'tac | tail -n +2' works on Linux, but macOS doesn't bundle tac.
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
