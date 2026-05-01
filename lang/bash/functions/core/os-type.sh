#!/usr/bin/env bash

_koopa_os_type() {
    # """
    # Operating system type.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    app['uname']="$(_koopa_locate_uname --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['uname']}" -s \
        | "${app['tr']}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
