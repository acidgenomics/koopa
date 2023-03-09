#!/bin/sh

_koopa_default_shell_name() {
    # """
    # Default shell name.
    # @note Updated 2022-11-28.
    # """
    local shell str
    shell="${SHELL:-sh}"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    _koopa_print "$str"
    return 0
}
