#!/usr/bin/env bash

koopa_current_pypi_package_version() {
    # """
    # Current Python package version at PyPi.
    # @note Updated 2023-12-22.
    #
    # Our awk command removes empty lines with NF, trims whitespace, and then
    # prints the second column in the string, which contains the version.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk)"
    app['curl']="$(koopa_locate_curl)"
    app['pup']="$(koopa_locate_pup)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['url']="https://pypi.org/project/${dict['name']}/"
    # shellcheck disable=SC2016
    dict['version']="$( \
        "${app['curl']}" -s "${dict['url']}" \
            | "${app['pup']}" 'h1 text{}' \
            | "${app['awk']}" 'NF {$1=$1; print $2}' \
    )"
    [[ -n "${dict['version']}" ]] || return 1
    koopa_print "${dict['version']}"
    return 0
}
