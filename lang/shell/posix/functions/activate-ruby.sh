#!/bin/sh

koopa_activate_ruby() {
    # """
    # Activate Ruby gems.
    # @note Updated 2022-05-12.
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/ruby" ] || return 0
    prefix="$(koopa_ruby_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export GEM_HOME="$prefix"
    return 0
}
