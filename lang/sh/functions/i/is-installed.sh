#!/bin/sh

# FIXME This check is failing for systems that use lmod during koopa install.

_koopa_is_installed() {
    # """
    # Is the requested program name installed?
    # @note Updated 2023-03-27.
    #
    # @examples
    # TRUE:
    # _koopa_is_installed 'bash'
    #
    # FALSE:
    # _koopa_is_installed '_koopa_koopa_prefix'
    # """
    for __kvar_cmd in "$@"
    do
        __kvar_string="$(command -v "$__kvar_cmd")"
        [ -x "$__kvar_string" ] && continue
        unset -v __kvar_cmd __kvar_string
        return 1
    done
    unset -v __kvar_cmd __kvar_string
    return 0
}
