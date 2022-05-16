#!/usr/bin/env bash

koopa_os_version() {
    # """
    # Operating system version.
    # @note Updated 2022-02-27.
    #
    # Keep in mind that 'uname' returns Darwin kernel version for macOS.
    # """
    local str
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        str="$(koopa_linux_os_version)"
    elif koopa_is_macos
    then
        str="$(koopa_macos_os_version)"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
