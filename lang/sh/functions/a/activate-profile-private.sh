#!/bin/sh

_koopa_activate_profile_private() {
    # """
    # Source private profile file.
    # @note Updated 2023-04-12.
    # """
    __kvar_file="${HOME:?}/.profile-private"
    if [ ! -r "$__kvar_file" ]
    then
        unset -v __kvar_file
        return 0
    fi
    # shellcheck source=/dev/null
    . "$__kvar_file"
    unset -v __kvar_file
    return 0
}
