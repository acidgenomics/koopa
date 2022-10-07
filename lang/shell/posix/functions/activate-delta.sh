#!/bin/sh

# FIXME This is too verbose on Ubuntu instance.
# This alias issue is only seen when using Bash as login shell..

koopa_activate_delta() {
    # """
    # Activate delta (git-delta) diff tool.
    # @note Updated 2022-10-07.
    #
    # This function dynamically updates dark/light color mode.
    # """
    local color_mode prefix source_bn source_file target_file target_link_bn
    [ -x "$(koopa_bin_prefix)/delta" ] || return 0
    prefix="$(koopa_xdg_config_home)/delta"
    [ -d "$prefix" ] || return 0
    color_mode="$(koopa_color_mode)"
    source_bn="theme-${color_mode}.gitconfig"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/theme.gitconfig"
    if [ -h "$target_file" ] && koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    koopa_is_alias 'ln' && unalias 'ln'
    command -v ln # FIXME
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}
