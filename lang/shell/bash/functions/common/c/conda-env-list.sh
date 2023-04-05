#!/usr/bin/env bash

koopa_conda_env_list() {
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2022-08-26.
    # """
    local app str
    declare -A app
    koopa_assert_has_no_args "$#"
    app['conda']="$(koopa_locate_conda)"
    [[ -x "${app['conda']}" ]] || exit 1
    str="$("${app['conda']}" env list --json --quiet)"
    koopa_print "$str"
    return 0
}
