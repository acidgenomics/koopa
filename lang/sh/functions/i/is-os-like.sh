#!/bin/sh

_koopa_is_os_like() {
    # """
    # Does the current operating system match an expected distribution?
    # @note Updated 2023-03-11.
    #
    # For example, this will match both Debian and Ubuntu when checking against
    # 'debian' value.
    # """
    __kvar_id="${1:?}"
    if _koopa_is_os "$__kvar_id"
    then
        unset __kvar_id
        return 0
    fi
    __kvar_file='/etc/os-release'
    if [ ! -r "$__kvar_file" ]
    then
        unset -v __kvar_file __kvar_id
        return 1
    fi
    if grep 'ID=' "$__kvar_file" | grep -q "$__kvar_id"
    then
        unset -v __kvar_file __kvar_id
        return 0
    fi
    if grep 'ID_LIKE=' "$__kvar_file" | grep -q "$__kvar_id"
    then
        unset -v __kvar_file __kvar_id
        return 0
    fi
    unset -v __kvar_file __kvar_id
    return 1
}
