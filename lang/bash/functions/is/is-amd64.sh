#!/usr/bin/env bash

_koopa_is_amd64() {
    # """
    # Is the architecture AMD 64-bit (Intel x86 64-bit)?
    # @note Updated 2025-01-03.
    # """
    case "$(_koopa_arch)" in
        'amd64' | 'x86_64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
