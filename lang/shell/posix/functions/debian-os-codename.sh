#!/bin/sh

koopa_debian_os_codename() {
    # """
    # Debian operating system codename.
    # @note Updated 2021-06-02.
    # """
    local x
    koopa_is_installed 'lsb_release' || return 0
    x="$(lsb_release -cs)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}
