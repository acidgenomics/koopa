#!/bin/sh

_koopa_xdg_data_dirs() {
    # """
    # XDG data dirs.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="${XDG_DATA_DIRS:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string='/usr/local/share:/usr/share'
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
