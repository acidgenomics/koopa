#!/usr/bin/env bash

koopa_conda_env_latest_version() {
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2022-01-17.
    # """
    local app dict str
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk)"
    app['conda']="$(koopa_locate_conda)"
    app['tail']="$(koopa_locate_tail)"
    [[ -x "${app['awk']}" ]] || exit 1
    [[ -x "${app['conda']}" ]] || exit 1
    [[ -x "${app['tail']}" ]] || exit 1
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
