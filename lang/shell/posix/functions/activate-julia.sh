#!/bin/sh

koopa_activate_julia() {
    # """
    # Activate Julia.
    # @note Updated 2022-04-12.
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/julia" ] || return 0
    prefix="$(koopa_julia_packages_prefix)"
    if [ -d "$prefix" ]
    then
        export JULIA_DEPOT_PATH="$prefix"
    fi
    return 0
}
