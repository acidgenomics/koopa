#!/usr/bin/env bash

_koopa_conda_env_latest_version() {
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2022-01-17.
    # """
    local -A app dict
    local str
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk)"
    app['conda']="$(_koopa_locate_conda)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['env_name']="${1:?}"
    # shellcheck disable=SC2016
    str="$( \
        "${app['conda']}" search --quiet "${dict['env_name']}" \
            | "${app['tail']}" -n 1 \
            | "${app['awk']}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
