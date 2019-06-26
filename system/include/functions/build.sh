#!/bin/sh

# Build utilities
# 2019-06-20.



# Fix the group permissions on the build directory.
# Modified 2019-06-26.
_koopa_build_chgrp() {
    path="$1"
    group="$(_koopa_build_prefix_group)"

    if _koopa_has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
    
    unset -v group path
}



# Symlink cellar into build directory.
# e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
# Modified 2019-06-22.
_koopa_build_link_cellar() {
    name="$1"
    version="$2"
    cellar_prefix="$(koopa cellar-prefix)/${name}/${version}"
    build_prefix="$(koopa build-prefix)"

    printf "Linking %s in %s.\n" "$cellar_prefix" "$build_prefix"
 
    _koopa_build_set_permissions "$cellar_prefix"
    
    if _koopa_has_sudo
    then
        sudo cp -frsv "$cellar_prefix/"* "$build_prefix/".
        _koopa_update_ldconfig
    else
        cp -frsv "$cellar_prefix/"* "$build_prefix/".
    fi

    _koopa_build_set_permissions "$build_prefix"
    
    unset -v build_prefix cellar_prefix name version
}



# Create the build directory.
# Modified 2019-06-20.
_koopa_build_mkdir() {
    path="$1"
    _koopa_assert_is_not_dir "$path"

    if _koopa_has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi

    _koopa_build_chgrp "$path"
    
    unset -v path
}



# Set the admin or regular user group automatically.
# Modified 2019-06-20.
_koopa_build_prefix_group() {
    # Standard user.
    ! _koopa_has_sudo && echo "$(whoami)" && return

    # Administrator.
    if groups | grep -Eq "\b(admin)\b"
    then
        # Darwin (macOS).
        group="admin"
    elif groups | grep -Eq "\b(sudo)\b"
    then
        # Debian.
        group="sudo"
    else
        # Fedora.
        group="wheel"
    fi
    echo "$group"
}



# Set permissions on program built from source.
# Modified 2019-06-20.
_koopa_build_set_permissions() {
    path="$1"
    
    if _koopa_has_sudo
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi

    _koopa_build_chgrp "$path"
    
    unset -v path
}
