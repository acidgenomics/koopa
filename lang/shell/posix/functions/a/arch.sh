#!/bin/sh

koopa_arch() {
    # """
    # Platform architecture.
    # @note Updated 2022-01-21.
    #
    # e.g. Intel: x86_64; ARM: aarch64.
    # """
    local x
    x="$(uname -m)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}
