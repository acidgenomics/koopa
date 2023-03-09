#!/bin/sh

_koopa_activate_alacritty() {
    # """
    # Activate Alacritty terminal client.
    # @note Updated 2022-08-04.
    #
    # This function dynamically updates dark/light color mode.
    #
    # @seealso
    # - Live config reload doesn't detect symlink change.
    #   https://github.com/alacritty/alacritty/issues/2237
    # """
    local conf_file color_file color_mode pattern prefix replacement
    _koopa_is_alacritty || return 0
    prefix="$(_koopa_xdg_config_home)/alacritty"
    [ -d "$prefix" ] || return 0
    conf_file="${prefix}/alacritty.yml"
    [ -f "$conf_file" ] || return 0
    color_mode="$(_koopa_color_mode)"
    color_file_bn="colors-${color_mode}.yml"
    color_file="${prefix}/${color_file_bn}"
    [ -f "$color_file" ] || return 0
    if ! grep -q "$color_file_bn" "$conf_file"
    then
        pattern="^  - \"~/\.config/alacritty/colors.*\.yml\"$"
        replacement="  - \"~/.config/alacritty/${color_file_bn}\""
        perl -i -l -p \
            -e "s|${pattern}|${replacement}|" \
            "$conf_file"
    fi
    # Clean up legacy 'colors.yml' file, if necessary.
    if [ -f "${prefix}/colors.yml" ]
    then
        rm "${prefix}/colors.yml"
    fi
    return 0
}
