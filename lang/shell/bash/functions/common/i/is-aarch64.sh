#!/usr/bin/env bash

koopa_is_aarch64() {
    # """
    # Is the architecture ARM 64-bit?
    # @note Updated 2023-01-10.
    #
    # a.k.a. "arm64" (arch2 return).
    # """
    [[ "$(koopa_arch)" = 'aarch64' ]]
}
