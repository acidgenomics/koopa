#!/usr/bin/env bash

koopa_is_r_package_installed() {
    # """
    # Is the requested R package installed?
    # @note Updated 2022-10-07.
    #
    # @examples
    # > koopa_is_r_package_installed 'BiocGenerics' 'S4Vectors'
    # """
    local -A app dict
    local pkg
    koopa_assert_has_args "$#"
    app['r']="$(koopa_locate_r)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$(koopa_r_packages_prefix "${app['r']}")"
    for pkg in "$@"
    do
        [[ -d "${dict['prefix']}/${pkg}" ]] || return 1
    done
    return 0
}
