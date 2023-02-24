#!/bin/sh

_koopa_is_os_like() {
    # """
    # Does the current operating system match an expected distribution?
    # @note Updated 2023-02-24.
    #
    # For example, this will match both Debian and Ubuntu when checking against
    # 'debian' value.
    # """
    local file id
    file='/etc/os-release'
    id="${1:?}"
    koopa_is_os "$id" && return 0
    [ -r "$file" ] || return 1
    grep 'ID=' "$file" | grep -q "$id" && return 0
    grep 'ID_LIKE=' "$file" | grep -q "$id" && return 0
    return 1
}
