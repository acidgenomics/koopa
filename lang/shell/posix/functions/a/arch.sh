#!/bin/sh

_koopa_arch() {
    # """
    # Platform architecture.
    # @note Updated 2023-03-11.
    #
    # e.g. Intel: x86_64; ARM: aarch64.
    # """
    __kvar_string="$(uname -m)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    return 0
}
