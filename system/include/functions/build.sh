#!/bin/sh

# Build utilities
# 2019-06-20.



# Fix the group permissions on the build directory.
# Modified 2019-06-20.
_koopa_build_chgrp() {
    local path
    local group

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
}



# Create the build directory.
# Modified 2019-06-20.
_koopa_build_mkdir() {
    local path
    
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
}



# Return the installation prefix to use.
# Modified 2019-06-20.
_koopa_build_prefix() {
    if _koopa_has_sudo
    then
        if echo "$KOOPA_DIR" | grep -Eq "^/opt/"
        then
            prefix="${KOOPA_DIR}/local"
        else
            prefix="/usr/local"
        fi
    else
        prefix="${HOME}/.local"
    fi
    mkdir -p "$prefix"
    echo "$prefix"
}



# Set the admin or regular user group automatically.
# Modified 2019-06-20.
_koopa_build_prefix_group() {
    # Standard user.
    ! _koopa_has_sudo && return "$(whoami)"

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
    local path="$1"
    
    if _koopa_has_sudo
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi

    _koopa_build_chgrp "$path"
}



# Symlink cellar into local build directory.
# e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
# Modified 2019-06-20.
_koopa_link_cellar() {
    local name="$1"
    local version="$2"
    local prefix="${KOOPA_CELLAR_PREFIX}/${name}/${version}"

    printf "Linking %s in %s.\n" "$prefix" "$KOOPA_BUILD_PREFIX"
 
    _koopa_build_set_permissions "$prefix"
    
    if _koopa_has_sudo
    then
        sudo cp -frsv "$prefix/"* "$KOOPA_BUILD_PREFIX"
        _koopa_update_ldconfig
    else
        cp -frsv "$prefix/"* "$KOOPA_BUILD_PREFIX"
    fi

    _koopa_build_set_permissions "$KOOPA_BUILD_PREFIX"
}

