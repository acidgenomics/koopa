#!/usr/bin/env bash

koopa_conda_env_latest_version() {
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2022-01-17.
    # """
    local app dict str
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [conda]="$(koopa_locate_mamba_or_conda)"
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
    )
    # shellcheck disable=SC2016
    str="$( \
        "${app[conda]}" search --quiet "${dict[env_name]}" \
            | "${app[tail]}" -n 1 \
            | "${app[awk]}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
