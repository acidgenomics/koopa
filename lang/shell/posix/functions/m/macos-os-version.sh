#!/bin/sh

_koopa_macos_os_version() {
    # """
    # macOS version.
    # @note Updated 2023-03-11.
    # """
    __kvar_string="$(/usr/bin/sw_vers -productVersion)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
