#!/usr/bin/env bash

koopa_conda_env_list() {
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2022-08-26.
    # """
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['conda']="$(koopa_locate_conda)"
    koopa_assert_is_executable "${app[@]}"
    str="$("${app['conda']}" env list --json --quiet)"
    koopa_print "$str"
    return 0
}
