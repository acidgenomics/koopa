#!/bin/sh

_koopa_default_shell_name() {
    # """
    # Default shell name.
    # @note Updated 2023-03-10.
    # """
    __kvar_shell="${SHELL:-sh}"
    __kvar_shell="$(basename "$__kvar_shell")"
    [ -n "$__kvar_shell" ] || return 1
    _koopa_print "$__kvar_shell"
    unset -v __kvar_shell
    return 0
}
