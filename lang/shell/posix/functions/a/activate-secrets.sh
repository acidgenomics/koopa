#!/bin/sh

_koopa_activate_secrets() {
    # """
    # Source secrets file.
    # @note Updated 2023-03-10.
    # """
    __kvar_file="${1:-}"
    [ -z "$__kvar_file" ] && __kvar_file="${HOME:?}/.secrets"
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
