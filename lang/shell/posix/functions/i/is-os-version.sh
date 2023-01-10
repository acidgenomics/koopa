#!/bin/sh

koopa_is_os_version() {
    # """
    # Is a specific OS version?
    # @note Updated 2022-01-21.
    # """
    local file grep version
    file='/etc/os-release'
    grep='grep'
    version="${1:?}"
    [ -f "$file" ] || return 1
    "$grep" -q "VERSION_ID=\"${version}" "$file"
}
