#!/bin/sh

_koopa_xdg_data_home() {
    # """
    # XDG data home.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="${XDG_DATA_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="${HOME:?}/.local/share"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
