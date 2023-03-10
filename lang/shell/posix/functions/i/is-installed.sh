#!/bin/sh

_koopa_is_installed() {
    # """
    # Is the requested program name installed?
    # @note Updated 2023-03-10.
    # """
    for __kvar_cmd in "$@"
    do
        command -v "$__kvar_cmd" >/dev/null || return 1
    done
    unset -v __kvar_cmd
    return 0
}
