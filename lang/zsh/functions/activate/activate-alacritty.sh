#!/usr/bin/env zsh

_koopa_activate_alacritty() {
    _koopa_is_alacritty || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/alacritty"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conf_file
    conf_file="${prefix}/alacritty.toml"
    if [[ ! -f "$conf_file" ]]
    then
        return 0
    fi
    local color_file_bn
    color_file_bn="colors-$(_koopa_color_mode).toml"
    local color_file
    color_file="${prefix}/${color_file_bn}"
    if [[ ! -f "$color_file" ]]
    then
        return 0
    fi
    if ! grep -q "$color_file_bn" "$conf_file"
    then
        local pattern
        pattern='colors-.+\.toml'
        local replacement
        replacement="${color_file_bn}"
        perl -i -l -p \
            -e "s|${pattern}|${replacement}|" \
            "$conf_file"
    fi
    return 0
}
