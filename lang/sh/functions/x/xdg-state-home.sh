#!/bin/sh

_koopa_xdg_state_home() {
    # """
    # XDG state home.
    # @note Updated 2023-03-30.
    # """
    __kvar_string="${XDG_STATE_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="$(_koopa_xdg_local_home)/state"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
