#!/usr/bin/env bash

koopa_datetime() {
    # """
    # Datetime string.
    # @note Updated 2022-08-29.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    local -A app
    app['date']="$(koopa_locate_date --allow-system)"
    [[ -x "${app['date']}" ]] || exit 1
    str="$("${app['date']}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
