#!/usr/bin/env bash

koopa_parallel_version() {
    # """
    # GNU parallel version.
    # @note Updated 2022-03-21.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [parallel]="${1:-}"
    )
    [[ -z "${app[parallel]}" ]] && app[parallel]="$(koopa_locate_parallel)"
    str="$( \
        "${app[parallel]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
