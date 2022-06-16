#!/usr/bin/env bash

koopa_is_r_package_installed() {
    # """
    # Is the requested R package installed?
    # @note Updated 2022-06-15.
    #
    # @examples
    # > koopa_is_r_package_installed 'BiocGenerics' 'S4Vectors'
    # """
    local app dict pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    [[ -x "${app[r]}" ]] || return 1
    declare -A dict
    dict[version]="$(koopa_get_version "${app[r]}")"
    dict[prefix]="$(koopa_r_packages_prefix "${dict[version]}")"
    for pkg in "$@"
    do
        [[ -d "${dict[prefix]}/${pkg}" ]] || return 1
    done
    return 0
}
