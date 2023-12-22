#!/usr/bin/env bash

koopa_current_pypi_version() {
    # """
    # Current Python package version at PyPi.
    # @note Updated 2023-12-22.
    #
    # Our awk command removes empty lines with NF, trims whitespace, and then
    # prints the second column in the string, which contains the version.
    #
    # @examples
    # > koopa_current_pypi_version 'pip' 'setuptools' 'wheel'
    # # 23.3.2
    # # 69.0.2
    # # 0.42.0
    # """
    local -A app dict
    local name
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['curl']="$(koopa_locate_curl)"
    app['pup']="$(koopa_locate_pup)"
    koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local -A dict
        dict['name']="$name"
        dict['url']="https://pypi.org/project/${dict['name']}/"
        # shellcheck disable=SC2016
        dict['version']="$( \
            "${app['curl']}" -s "${dict['url']}" \
                | "${app['pup']}" 'h1 text{}' \
                | "${app['awk']}" 'NF {$1=$1; print $2}' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        koopa_print "${dict['version']}"
    done
    return 0
}
