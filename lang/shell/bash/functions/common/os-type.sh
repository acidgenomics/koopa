#!/usr/bin/env bash

koopa_os_type() {
    # """
    # Operating system type.
    # @note Updated 2022-02-09.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
        [uname]="$(koopa_locate_uname)"
    )
    str="$( \
        "${app[uname]}" -s \
        | "${app[tr]}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
