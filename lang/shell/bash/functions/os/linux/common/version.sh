#!/usr/bin/env bash

koopa_linux_os_version() { # {{{1
    # """
    # Linux OS version.
    # @note Updated 2021-11-16.
    # """
    local app x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [uname]="$(koopa_locate_uname)"
    )
    x="$("${app[uname]}" -r)"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}
