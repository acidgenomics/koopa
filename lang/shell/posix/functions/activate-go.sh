#!/bin/sh

koopa_activate_go() {
    # """
    # Activate Go.
    # @note Updated 2022-05-12.
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/go" ] || return 0
    prefix="$(koopa_go_packages_prefix)"
    [ -d "$prefix" ] || return 0
    GOPATH="$(koopa_go_packages_prefix)"
    export GOPATH
    return 0
}
