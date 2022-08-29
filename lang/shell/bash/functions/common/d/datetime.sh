#!/usr/bin/env bash

koopa_datetime() {
    # """
    # Datetime string.
    # @note Updated 2022-08-29.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app
    app['date']="$(koopa_locate_date --allow-missing)"
    [[ ! -x "${app['date']}" ]] && app['date']='/usr/bin/date'
    [[ -x "${app['date']}" ]] || return 1
    str="$("${app['date']}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
