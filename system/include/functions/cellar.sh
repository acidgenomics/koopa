#!/bin/sh

# Cellar functions.
# Modified 2019-06-26.



# Symlink cellar into build directory.
# e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
# Modified 2019-06-22.
_koopa_link_cellar() {
    name="$1"
    version="$2"
    cellar_prefix="$(koopa cellar-prefix)/${name}/${version}"
    build_prefix="$(koopa build-prefix)"

    printf "Linking %s in %s.\n" "$cellar_prefix" "$build_prefix"

    _koopa_build_set_permissions "$cellar_prefix"
    cp -frsv "$cellar_prefix/"* "$build_prefix/".
    _koopa_build_set_permissions "$build_prefix"
    _koopa_has_sudo && _koopa_update_ldconfig
    
    unset -v build_prefix cellar_prefix name version
}

