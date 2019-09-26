#!/bin/sh
# shellcheck disable=SC2039



# Extract the file basename without extension.
#
# Examples:
# _koopa_basename_sans_ext "hello-world.txt"
# ## hello-world
#
# _koopa_basename_sans_ext "hello-world.tar.gz"
# ## hello-world.tar
#
# See also: _koopa_file_ext
#
# Updated 2019-09-26.
_koopa_basename_sans_ext() {
    _koopa_assert_has_file_ext "$1"
    printf "%s\n" "${1%.*}"
}



# Extract the file basename prior to any dots in file name.
#
# Examples
# _koopa_basename_sans_ext2 "hello-world.tar.gz"
# ## hello-world
#
# See also: _koopa_file_ext2
#
# Updated 2019-09-26.
_koopa_basename_sans_ext2() {
    _koopa_assert_has_file_ext "$1"
    echo "$1" | cut -d '.' -f 1
}



# Updated 2019-08-18.
_koopa_bash_version() {
    bash --version | \
        head -n 1 | \
        cut -d ' ' -f 4 | \
        cut -d '(' -f 1
        # > cut -d '.' -f 1-2
}



# Fix the group permissions on the build directory.
# Updated 2019-06-26.
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
# Updated 2019-06-20.
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



# Build string for `make` configuration.
# Use this for `configure --build` flag.
# # - AWS:    x86_64-amzn-linux-gnu
# - RedHat: x86_64-redhat-linux-gnu
# - Darwin: x86_64-darwin15.6.0
# # Updated 2019-07-09.
_koopa_build_os_string() {
    local mach
    local os_type
    local string

    mach="$(uname -m)"
    
    if _koopa_is_darwin
    then
        string="${mach}-${OSTYPE}"
    elif _koopa_is_linux
    then
        # This will distinguish between RedHat, Amazon, and other distros
        # instead of just returning "linux". Note that we're substituting
        # "redhat" instead of "rhel" here, when applicable.
        os_type="$(_koopa_os_type)"
        if echo "$os_type" | grep -q "rhel"
        then
            os_type="redhat"
        fi
        string="${mach}-${os_type}-${OSTYPE}"
    fi

    echo "$string"
}



# Return the installation prefix to use.
# Updated 2019-06-27.
_koopa_build_prefix() {
    local prefix

    if _koopa_is_shared && _koopa_has_sudo
    then
        if echo "$KOOPA_HOME" | grep -Eq "^/opt/"
        then
            prefix="${KOOPA_HOME}/local"
        else
            prefix="/usr/local"
        fi
    else
        prefix="${HOME}/.local"
    fi

    echo "$prefix"
}



# Set the admin or regular user group automatically.
# Updated 2019-07-09.
_koopa_build_prefix_group() {
    local group

    # Standard user.
    ! _koopa_has_sudo && whoami && return 0

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
# Updated 2019-06-27.
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
