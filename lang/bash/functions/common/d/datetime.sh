#!/usr/bin/env bash

koopa_datetime() {
    # """
    # Datetime string.
    # @note Updated 2022-08-29.
    # """
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['date']="$(koopa_locate_date --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    str="$("${app['date']}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
