#!/bin/sh

# Build functions
# Modified 2019-06-27.



# Fix the group permissions on the build directory.
# Modified 2019-06-26.
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



# Set the admin or regular user group automatically.
# Modified 2019-06-27.
_koopa_build_prefix_group() {
    local group

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
# Modified 2019-06-27.
_koopa_build_set_permissions() {
    local path
    path="$1"
    
    if _koopa_has_sudo
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi

    _koopa_build_chgrp "$path"
}
