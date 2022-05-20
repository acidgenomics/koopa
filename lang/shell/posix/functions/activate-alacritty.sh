#!/bin/sh

koopa_activate_alacritty() {
    # """
    # Activate Alacritty terminal client.
    # @note Updated 2022-05-06.
    #
    # This function dynamically updates dark/light color mode.
    #
    # @seealso
    # - Live config reload doesn't detect symlink change.
    #   https://github.com/alacritty/alacritty/issues/2237
    # """
    local color_mode prefix source_bn source_file target_file target_link_bn
    koopa_is_alacritty || return 0
    prefix="$(koopa_xdg_config_home)/alacritty"
    [ -d "$prefix" ] || return 0
    color_mode="$(koopa_color_mode)"
    source_bn="colors-${color_mode}.yml"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/colors.yml"
    if [ -h "$target_file" ] && koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    ln -fns "$source_file" "$target_file"
    return 0
}
