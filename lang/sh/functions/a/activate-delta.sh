#!/bin/sh

_koopa_activate_delta() {
    # """
    # Activate delta (git-delta) diff tool.
    # @note Updated 2025-02-20.
    # """
    [ -x "$(_koopa_bin_prefix)/delta" ] || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/delta"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_source_bn="theme-$(_koopa_color_mode).gitconfig"
    __kvar_source_file="${__kvar_prefix}/${__kvar_source_bn}"
    if [ ! -f "$__kvar_source_file" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_source_bn \
            __kvar_source_file
        return 0
    fi
    __kvar_target_file="${__kvar_prefix}/theme.gitconfig"
    if [ -h "$__kvar_target_file" ] && _koopa_is_installed 'readlink'
    then
        __kvar_target_link_bn="$(readlink "$__kvar_target_file")"
        if [ "$__kvar_target_link_bn" = "$__kvar_source_bn" ]
        then
            unset -v \
                __kvar_prefix \
                __kvar_source_bn \
                __kvar_source_file \
                __kvar_target_file \
                __kvar_target_link_bn
            return 0
        fi
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns \
        "$__kvar_source_file" \
        "$__kvar_target_file" \
        >/dev/null 2>&1
    unset -v \
        __kvar_prefix \
        __kvar_source_bn \
        __kvar_source_file \
        __kvar_target_file \
        __kvar_target_link_bn
    return 0
}
