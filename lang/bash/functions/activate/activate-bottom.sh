#!/usr/bin/env bash

_koopa_activate_bottom() {
    [[ -x "$(_koopa_bin_prefix)/btm" ]] || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/bottom"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local source_bn
    source_bn="bottom-$(_koopa_color_mode).toml"
    local source_file
    source_file="${prefix}/${source_bn}"
    if [[ ! -f "$source_file" ]]
    then
        return 0
    fi
    local target_file
    target_file="${prefix}/bottom.toml"
    if [[ -h "$target_file" ]] && _koopa_is_installed 'readlink'
    then
        local target_link_bn
        target_link_bn="$(readlink "$target_file")"
        if [[ "$target_link_bn" = "$source_bn" ]]
        then
            return 0
        fi
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}
