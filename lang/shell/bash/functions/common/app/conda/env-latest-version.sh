#!/usr/bin/env bash

koopa::conda_env_latest_version() { # {{{1
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2022-01-17.
    # """
    local app dict str
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [conda]="$(koopa::locate_mamba_or_conda)"
        [tail]="$(koopa::locate_tail)"
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
    koopa::print "$str"
    return 0
}
