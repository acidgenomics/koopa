#!/bin/sh

koopa_julia_packages_prefix() {
    # """
    # Julia packages (depot) library prefix.
    # @note Updated 2021-06-14.
    #
    # @usage koopa_julia_packages_prefix [VERSION]
    #
    # In the shell environment, check 'JULIA_DEPOT_PATH'.
    # Inside Julia, check 'DEPOT_PATH'.
    # """
    __koopa_packages_prefix 'julia' "$@"
}
