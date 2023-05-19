#!/usr/bin/env bash

koopa_is_aarch64() {
    # """
    # Is the architecture ARM 64-bit?
    # @note Updated 2023-03-19.
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
