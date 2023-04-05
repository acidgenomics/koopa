#!/usr/bin/env bash

koopa_os_type() {
    # """
    # Operating system type.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['tr']="$(koopa_locate_tr --allow-system)"
    app['uname']="$(koopa_locate_uname --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['uname']}" -s \
        | "${app['tr']}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
