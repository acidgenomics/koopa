#!/bin/sh

_koopa_activate_bat() {
    # """
    # Activate bat configuration.
    # @note Updated 2023-03-09.
    #
    # Ensure this follows '_koopa_activate_color_mode'.
    # """
    [ -x "$(_koopa_bin_prefix)/bat" ] || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/bat"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_color_mode="$(_koopa_color_mode)"
    __kvar_conf_file="${__kvar_prefix}/config-${__kvar_color_mode}"
    if [ ! -f "$__kvar_conf_file" ]
    then
        unset -v __kvar_color_mode __kvar_conf_file __kvar_prefix
        return 0
    fi
    export BAT_CONFIG_PATH="$__kvar_conf_file"
    unset -v __kvar_color_mode __kvar_conf_file __kvar_prefix
    return 0
}
