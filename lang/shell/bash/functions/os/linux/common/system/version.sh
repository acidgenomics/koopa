#!/usr/bin/env bash

koopa::linux_os_version() { # {{{1
    # """
    # Linux OS version.
    # @note Updated 2021-11-16.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [uname]="$(koopa::locate_uname)"
    )
    x="$("${app[uname]}" -r)"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
