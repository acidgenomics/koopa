#!/usr/bin/env bash

koopa_conda_env_latest_version() {
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2022-01-17.
    # """
    local -A app dict
    local str
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk)"
    app['conda']="$(koopa_locate_conda)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['env_name']="${1:?}"
    # shellcheck disable=SC2016
    str="$( \
        "${app['conda']}" search --quiet "${dict['env_name']}" \
            | "${app['tail']}" -n 1 \
            | "${app['awk']}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
