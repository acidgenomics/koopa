#!/bin/sh

koopa_is_aarch64() {
    # """
    # Is the architecture ARM 64-bit?
    # @note Updated 2021-11-02.
    #
    # a.k.a. "arm64" (arch2 return).
    # """
    [ "$(koopa_arch)" = 'aarch64' ]
}
