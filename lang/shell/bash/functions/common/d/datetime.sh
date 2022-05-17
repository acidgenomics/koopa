#!/usr/bin/env bash

koopa_datetime() {
    # """
    # Datetime string.
    # @note Updated 2022-01-20.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [date]="$(koopa_locate_date)"
    )
    str="$("${app[date]}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
