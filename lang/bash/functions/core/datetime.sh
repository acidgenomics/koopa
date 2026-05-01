#!/usr/bin/env bash

_koopa_datetime() {
    # """
    # Datetime string.
    # @note Updated 2022-08-29.
    # """
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['date']="$(_koopa_locate_date --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$("${app['date']}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
