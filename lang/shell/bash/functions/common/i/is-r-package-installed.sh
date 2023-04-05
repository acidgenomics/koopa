#!/usr/bin/env bash

# FIXME Need to allow user to specify which R.

koopa_is_r_package_installed() {
    # """
    # Is the requested R package installed?
    # @note Updated 2022-10-07.
    #
    # @examples
    # > koopa_is_r_package_installed 'BiocGenerics' 'S4Vectors'
    # """
    local app dict pkg
    koopa_assert_has_args "$#"
    local -A app
    local -A dict
    app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || exit 1
    dict['prefix']="$(koopa_r_packages_prefix "${app['r']}")"
    for pkg in "$@"
    do
        [[ -d "${dict['prefix']}/${pkg}" ]] || return 1
    done
    return 0
}
