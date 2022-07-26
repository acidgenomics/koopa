#!/bin/sh

koopa_activate_julia() {
    # """
    # Activate Julia.
    # @note Updated 2022-07-26.
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/julia" ] || return 0
    prefix="$(koopa_julia_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export JULIA_DEPOT_PATH="$prefix"
    return 0
}
