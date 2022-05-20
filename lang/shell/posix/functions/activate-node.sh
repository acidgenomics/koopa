#!/bin/sh

koopa_activate_node() {
    # """
    # Activate Node.js (and NPM).
    # @note Updated 2022-05-12.
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/node" ] || return 0
    prefix="$(koopa_node_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export NPM_CONFIG_PREFIX="$prefix"
    return 0
}
