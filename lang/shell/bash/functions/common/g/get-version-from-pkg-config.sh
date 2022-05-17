#!/usr/bin/env bash

koopa_get_version_from_pkg_config() {
    # """
    # Get a library version via pkg-config.
    # @note Updated 2022-02-27.
    # """
    local app pkg str
    koopa_assert_has_args_eq "$#" 1
    pkg="${1:?}"
    declare -A app=(
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    str="$("${app[pkg_config]}" --modversion "$pkg")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
