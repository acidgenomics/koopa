#!/bin/sh

_koopa_activate_bat() {
    # """
    # Activate bat configuration.
    # @note Updated 2022-05-12.
    #
    # Ensure this follows '_koopa_activate_color_mode'.
    # """
    local color_mode conf_file prefix
    [ -x "$(_koopa_bin_prefix)/bat" ] || return 0
    prefix="$(_koopa_xdg_config_home)/bat"
    [ -d "$prefix" ] || return 0
    color_mode="$(_koopa_color_mode)"
    conf_file="${prefix}/config-${color_mode}"
    [ -f "$conf_file" ] || return 0
    export BAT_CONFIG_PATH="$conf_file"
    return 0
}
