#!/bin/sh
# shellcheck disable=SC2039



# Symlink cellar into build directory.
# e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
# Updated 2019-06-27.
_koopa_link_cellar() {
    local name
    local version
    local cellar_prefix
    local build_prefix

    name="$1"
    version="$2"
    cellar_prefix="$(_koopa_cellar_prefix)/${name}/${version}"
    build_prefix="$(_koopa_build_prefix)"

    printf "Linking %s in %s.\n" "$cellar_prefix" "$build_prefix"

    _koopa_build_set_permissions "$cellar_prefix"
    cp -frsv "$cellar_prefix/"* "$build_prefix/".
    _koopa_build_set_permissions "$build_prefix"
    _koopa_has_sudo && _koopa_update_ldconfig
}



# Locate a program and add its name as a prefix.
# e.g. return `bash: /usr/bin/bash`.
# Updated 2019-07-09.
_koopa_locate() {
    local command
    local name
    local path

    command="$1"
    name="${2:-$command}"
    path="$(_koopa_quiet_which2 "$command")"
    
    if [ -z "$path" ]
    then
        path="[missing]"
    else
        path="$(realpath "$path")"
    fi
    printf "%s: %s" "$name" "$path"
}
