#!/bin/sh

koopa_add_config_link() {
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2022-09-12.
    # """
    local config_prefix dest_file dest_name source_file
    config_prefix="$(koopa_config_prefix)"
    koopa_is_alias 'ln' && unalias 'ln'
    koopa_is_alias 'mkdir' && unalias 'mkdir'
    koopa_is_alias 'rm' && unalias 'rm'
    while [ "$#" -ge 2 ]
    do
        source_file="${1:?}"
        dest_name="${2:?}"
        shift 2
        [ -e "$source_file" ] || continue
        dest_file="${config_prefix}/${dest_name}"
        if [ -L "$dest_file" ] && [ -e "$dest_file" ]
        then
            continue
        fi
        mkdir -p "$config_prefix"
        rm -fr "$dest_file"
        ln -s "$source_file" "$dest_file"
    done
    return 0
}
