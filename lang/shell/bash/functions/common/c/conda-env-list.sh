#!/usr/bin/env bash

koopa_conda_env_list() {
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2022-01-17.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_mamba_or_conda)"
    )
    str="$("${app[conda]}" env list --json --quiet)"
    koopa_print "$str"
    return 0
}
