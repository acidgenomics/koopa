#!/bin/sh

koopa_activate_bottom() {
    # """
    # Activate bottom.
    # @note Updated 2022-12-08.
    # """
    local color_mode prefix source_bn source_file target_file target_link_bn
    [ -x "$(koopa_bin_prefix)/btm" ] || return 0
    prefix="$(koopa_xdg_config_home)/bottom"
    [ -d "$prefix" ] || return 0
    color_mode="$(koopa_color_mode)"
    source_bn="bottom-${color_mode}.toml"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/bottom.toml"
    if [ -h "$target_file" ] && koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}
