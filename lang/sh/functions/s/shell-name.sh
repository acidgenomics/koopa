#!/bin/sh

_koopa_shell_name() {
    # """
    # Current shell name.
    # @note Updated 2024-07-09.
    # """
    __kvar_shell="$(_koopa_locate_shell)"
    __kvar_shell="$(basename "$__kvar_shell")"
    [ -n "$__kvar_shell" ] || return 1
    _koopa_print "$__kvar_shell"
    unset -v __kvar_shell
    return 0
}
