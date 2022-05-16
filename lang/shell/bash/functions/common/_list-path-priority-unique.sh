#!/usr/bin/env bash

__koopa_list_path_priority_unique() {
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2022-02-11.
    # """
    local app str
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [tac]="$(koopa_locate_tac)"
    )
    # shellcheck disable=SC2016
    str="$( \
        __koopa_list_path_priority "$@" \
            | "${app[tac]}" \
            | "${app[awk]}" '!a[$0]++' \
            | "${app[tac]}" \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
