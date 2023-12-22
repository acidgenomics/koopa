#!/usr/bin/env bash

koopa_current_conda_package_version() {
    # """
    # Get the current version of a conda package.
    # @note Updated 2023-12-22.
    #
    # @examples
    # koopa_current_conda_package_version 'salmon' 'kallisto'
    # """
    local -A app
    local name
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['conda']="$(koopa_locate_conda)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local -A dict
        dict['name']="$name"
        # shellcheck disable=SC2016
        dict['version']="$( \
            "${app['conda']}" search "${dict['name']}" \
                | "${app['tail']}" -n 1 \
                | "${app['awk']}" '{print $2}' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        koopa_print "${dict['version']}"
    done
    return 0
}
