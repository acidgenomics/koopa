#!/usr/bin/env bash

koopa_openjdk_version() {
    # """
    # Java (OpenJDK) version.
    # @note Updated 2022-03-25.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [java]="${1:-}"
    )
    [[ -z "${app[java]}" ]] && app[java]="$(koopa_locate_java)"
    str="$( \
        "${app[java]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
