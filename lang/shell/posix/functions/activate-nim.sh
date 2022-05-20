#!/bin/sh

koopa_activate_nim() {
    # """
    # Activate Nim.
    # @note Updated 2022-05-12.
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/nim" ] || return 0
    prefix="$(koopa_nim_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export NIMBLE_DIR="$prefix"
    return 0
}
