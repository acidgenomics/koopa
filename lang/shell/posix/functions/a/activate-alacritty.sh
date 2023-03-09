#!/bin/sh

_koopa_activate_alacritty() {
    # """
    # Activate Alacritty terminal client.
    # @note Updated 2023-03-09.
    #
    # This function dynamically updates dark/light color mode.
    #
    # @seealso
    # - Live config reload doesn't detect symlink change.
    #   https://github.com/alacritty/alacritty/issues/2237
    # """
    _koopa_is_alacritty || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/alacritty"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_conf_file="${__kvar_prefix}/alacritty.yml"
    if [ ! -f "$__kvar_conf_file" ]
    then
        unset -v __kvar_conf_file __kvar_prefix
        return 0
    fi
    __kvar_color_mode="$(_koopa_color_mode)"
    __kvar_color_file_bn="colors-${__kvar_color_mode}.yml"
    __kvar_color_file="${__kvar_prefix}/${__kvar_color_file_bn}"
    if [ ! -f "$__kvar_color_file" ]
    then
        unset -v \
            __kvar_color_file \
            __kvar_color_file_bn \
            __kvar_color_mode \
            __kvar_conf_file \
            __kvar_prefix
        return 0
    fi
    if ! grep -q "$__kvar_color_file_bn" "$__kvar_conf_file"
    then
        __kvar_pattern="^  - \"~/\.config/alacritty/colors.*\.yml\"$"
        __kvar_replacement="  - \"~/.config/alacritty/${__kvar_color_file_bn}\""
        perl -i -l -p \
            -e "s|${__kvar_pattern}|${__kvar_replacement}|" \
            "$__kvar_conf_file"
    fi
    unset -v \
        __kvar_color_file \
        __kvar_color_file_bn \
        __kvar_color_mode \
        __kvar_conf_file \
        __kvar_pattern \
        __kvar_prefix \
        __kvar_replacement
    return 0
}
