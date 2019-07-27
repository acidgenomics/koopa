#!/bin/sh
## shellcheck disable=SC2039



## Symlink cellar into build directory.
## e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
## Updated 2019-06-27.
_koopa_link_cellar() {
    local name
    local version
    local cellar_prefix
    local build_prefix

    name="$1"
    version="$2"
    cellar_prefix="$(koopa cellar-prefix)/${name}/${version}"
    build_prefix="$(koopa build-prefix)"

    printf "Linking %s in %s.\n" "$cellar_prefix" "$build_prefix"

    _koopa_build_set_permissions "$cellar_prefix"
    cp -frsv "$cellar_prefix/"* "$build_prefix/".
    _koopa_build_set_permissions "$build_prefix"
    _koopa_has_sudo && _koopa_update_ldconfig
}



## Experimental: may not work well on all systems.
## Updated 2019-06-27.
_koopa_link_conda_env() {
    local env_name
    local env_prefix
    local build_prefix

    env_name="$1"
    env_prefix="$(koopa conda-prefix)/envs/${env_name}"
    build_prefix="$(koopa build-prefix)"

    printf "Linking %s in %s.\n" "$env_prefix" "$build_prefix"

    _koopa_build_set_permissions "$env_prefix"

    find "$env_prefix" \
        -maxdepth 1 \
        -mindepth 1 \
        ! -name "*conda*" \
        -print0 |
        xargs -0 -I {} cp -frsv {} "$build_prefix/".

    _koopa_build_set_permissions "$build_prefix"
    _koopa_has_sudo && _koopa_update_ldconfig
}



## Used by `koopa info`.
## Updated 2019-07-09.
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
