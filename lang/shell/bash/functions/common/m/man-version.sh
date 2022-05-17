#!/usr/bin/env bash

koopa_man_version() {
    # """
    # man-db version.
    # @note Updated 2022-03-27.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
        [man]="${1:-}"
    )
    [[ -z "${app[man]}" ]] && app[man]="$(koopa_locate_man)"
    str="$( \
        "${app[grep]}" \
            --extended-regexp \
            --only-matching \
            --text \
            'lib/man-db/libmandb-[.0-9]+\.dylib' \
            "${app[man]}" \
    )"
    [[ -n "$str" ]] || return 1
    koopa_extract_version "$str"
    return 0
}
