#!/bin/sh

koopa_macos_os_version() {
    # """
    # macOS version.
    # @note Updated 2022-04-08.
    # """
    local x
    x="$(sw_vers -productVersion)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}
