#!/usr/bin/env bash

koopa_is_amd64() {
    # """
    # Is the architecture AMD 64-bit (Intel x86 64-bit)?
    # @note Updated 2025-01-03.
    # """
    case "$(koopa_arch)" in
        'amd64' | 'x86_64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
