#!/bin/sh

_koopa_os_id() {
    # """
    # Operating system ID.
    # @note Updated 2023-02-28.
    #
    # Just return the OS platform ID (e.g. debian).
    # """
    local string
    string="$(koopa_os_string | cut -d '-' -f '1')"
    [ -n "$string" ] || return 1
    _koopa_print "$string"
    return 0
}
