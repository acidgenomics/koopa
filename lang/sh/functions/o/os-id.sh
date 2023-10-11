#!/bin/sh

_koopa_os_id() {
    # """
    # Operating system ID.
    # @note Updated 2023-10-11.
    #
    # Just return the OS platform ID (e.g. debian).
    # """
    __kvar_string="$(_koopa_os_string | cut -d '-' -f 1)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
