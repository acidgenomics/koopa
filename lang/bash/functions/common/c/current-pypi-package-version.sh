#!/usr/bin/env bash

koopa_current_pypi_package_version() {
    # """
    # Current Python package version at PyPi.
    # @note Updated 2025-12-30.
    #
    # Our awk command removes empty lines with NF, trims whitespace, and then
    # prints the second column in the string, which contains the version.
    #
    # @examples
    # > koopa_current_pypi_package_version 'setuptools' 'wheel'
    # # 80.9.0
    # # 0.45.1
    # """
    local -A app
    local name
    koopa_assert_has_args "$#"
    app['curl']="$(koopa_locate_curl)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local -A dict
        dict['name']="$name"
        dict['url']="https://pypi.org/pypi/${dict['name']}/json"
        # shellcheck disable=SC2016
        dict['version']="$( \
            "${app['curl']}" -s "${dict['url']}" \
                | "${app['jq']}" --raw-output '.info.version' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        koopa_print "${dict['version']}"
    done
    return 0
}
