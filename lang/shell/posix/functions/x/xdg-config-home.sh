#!/bin/sh

_koopa_xdg_config_home() {
    # """
    # XDG config home.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="${XDG_CONFIG_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="${HOME:?}/.config"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
