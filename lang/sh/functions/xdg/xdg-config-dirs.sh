#!/bin/sh

_koopa_xdg_config_dirs() {
    # """
    # XDG config dirs.
    # @note Updated 2023-03-09.
    # """
    __kvar_string="${XDG_CONFIG_DIRS:-}"
    if [ -z "$__kvar_string" ] 
    then
        __kvar_string='/etc/xdg'
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
