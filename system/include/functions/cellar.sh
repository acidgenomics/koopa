#!/bin/sh
## shellcheck disable=SC2039

## Cellar functions.
## Updated 2019-06-27.



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

