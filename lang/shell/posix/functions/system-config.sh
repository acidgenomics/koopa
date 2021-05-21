#!/bin/sh
# koopa nolint=coreutils

_koopa_add_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2020-12-11.
    # """
    local config_prefix dest_file dest_name source_file
    source_file="${1:?}"
    [ -e "$source_file" ] || return 0
    dest_name="${2:-}"
    [ -z "$dest_name" ] && dest_name="$(basename "$source_file")"
    config_prefix="$(_koopa_config_prefix)"
    dest_file="${config_prefix}/${dest_name}"
    [ -L "$dest_file" ] && return 0
    mkdir -p "$config_prefix"
    rm -fr "$dest_file"
    ln -fns "$source_file" "$dest_file"
    return 0
}
