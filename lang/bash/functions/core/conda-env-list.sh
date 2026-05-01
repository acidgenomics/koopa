#!/usr/bin/env bash

_koopa_conda_env_list() {
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2022-08-26.
    # """
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['conda']="$(_koopa_locate_conda)"
    _koopa_assert_is_executable "${app[@]}"
    str="$("${app['conda']}" env list --json --quiet)"
    _koopa_print "$str"
    return 0
}
