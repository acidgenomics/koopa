#!/bin/sh

_koopa_add_config_link() {
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2023-03-10.
    # """
    __kvar_config_prefix="$(_koopa_config_prefix)"
    _koopa_is_alias 'ln' && unalias 'ln'
    _koopa_is_alias 'mkdir' && unalias 'mkdir'
    _koopa_is_alias 'rm' && unalias 'rm'
    while [ "$#" -ge 2 ]
    do
        __kvar_source_file="${1:?}"
        __kvar_dest_name="${2:?}"
        shift 2
        [ -e "$__kvar_source_file" ] || continue
        __kvar_dest_file="${__kvar_config_prefix}/${__kvar_dest_name}"
        if [ -L "$__kvar_dest_file" ] && [ -e "$__kvar_dest_file" ]
        then
            continue
        fi
        mkdir -p "$__kvar_config_prefix" >/dev/null
        rm -fr "$__kvar_dest_file" >/dev/null
        ln -fns "$__kvar_source_file" "$__kvar_dest_file" >/dev/null
    done
    unset -v \
        __kvar_config_prefix \
        __kvar_dest_file \
        __kvar_dest_name \
        __kvar_source_file
    return 0
}
