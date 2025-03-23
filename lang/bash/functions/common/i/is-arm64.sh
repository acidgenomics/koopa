#!/usr/bin/env bash

koopa_is_arm64() {
    # """
    # Is the architecture ARM 64-bit?
    # @note Updated 2025-01-03.
    # """
    case "$(koopa_arch)" in
        'aarch64' | 'arm64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
