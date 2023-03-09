#!/bin/sh

_koopa_today() {
    # """
    # Today string.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="$(date '+%Y-%m-%d')"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
