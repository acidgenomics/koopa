#!/usr/bin/env zsh

_koopa_activate_kitty() {
    _koopa_is_kitty || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/kitty"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local source_bn
    source_bn="theme-$(_koopa_color_mode).conf"
    local source_file
    source_file="${prefix}/${source_bn}"
    if [[ ! -f "$source_file" ]]
    then
        return 0
    fi
    local target_file
    target_file="${prefix}/current-theme.conf"
    if [[ -h "$target_file" ]] && _koopa_is_installed 'readlink'
    then
        local target_link_bn
        target_link_bn="$(readlink "$target_file")"
        if [[ "$target_link_bn" = "$source_bn" ]]
        then
            return 0
        fi
    fi
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}
