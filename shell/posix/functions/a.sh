#!/bin/sh
# shellcheck disable=SC2039



# Add nested `bin/` and `sbin/` directories to PATH.
# Updated 2019-09-12.
_koopa_add_bins_to_path() {
    local relpath
    local prefix
    relpath="${1:-}"
    prefix="$KOOPA_HOME"
    [ -n "$relpath" ] && prefix="${prefix}/${relpath}"
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
}



# Add conda environment to PATH.
#
# Experimental: working method to improve pandoc and texlive on RHEL 7.
#
# Updated 2019-09-12.
_koopa_add_conda_env_to_path() {
    local env_name
    local env_list
    local prefix
    _koopa_is_installed conda || return 1
    env_name="$1"
    env_list="${2:-}"
    prefix="$(_koopa_conda_env_prefix "$env_name" "$env_list")"
    [ -n "$prefix" ] || return 1
    prefix="${prefix}/bin"
    [ -d "$prefix" ] || return 1
    _koopa_add_to_path_start "$prefix"
}



# Add a symlink into the koopa configuration directory.
#
# Examples:
# _koopa_add_config_link vimrc
# _koopa_add_config_link vim
#
# Updated 2019-09-23.
_koopa_add_config_link() {
    local config_dir
    config_dir="$(_koopa_config_dir)"
    local source_file
    source_file="$1"
    _koopa_assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    local dest_name
    dest_name="$2"
    local dest_file
    dest_file="${config_dir}/${dest_name}"
    rm -fv "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
}



# Add directory to end of PATH.
# Updated 2019-09-12.
_koopa_add_to_path_end() {
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${PATH}:${1}"
}



# Add directory to start of PATH.
# Updated 2019-09-12.
_koopa_add_to_path_start() {
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${1}:${PATH}"
}



# Assert that conda and Python virtual environments aren't active.
# Updated 2019-09-12.
_koopa_assert_has_no_environments() {
    if ! _koopa_has_no_environments
    then
        >&2 printf "Error: Active environment detected.\n"
        return 1
    fi
    return 0
}



# Assert that current user has sudo (admin) permissions.
# Updated 2019-09-12.
_koopa_assert_has_sudo() {
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        return 1
    fi
    return 0
}



# Assert that input is a directory.
# Updated 2019-09-12.
_koopa_assert_is_dir() {
    if [ ! -d "$1" ]
    then
        >&2 printf "Error: Not a directory: '%s'\n" "$1"
        return 1
    fi
    return 0
}



# FIXME Renamed this...update scripts.

# Assert that input exists on disk.
#
# Note that '-e' flag returns true for file, dir, or symlink.
#
# Updated 2019-09-23.
_koopa_assert_is_existing() {
    if [ ! -e "$1" ]
    then
        >&2 printf "Error: Does not exist: '%s'\n" "$1"
        return 1
    fi
    return 0
}



# Assert that input is a file.
# Updated 2019-09-12.
_koopa_assert_is_file() {
    if [ ! -f "$1" ]
    then
        >&2 printf "Error: Not a file: '%s'\n" "$1"
        return 1
    fi
    return 0
}



# Assert that platform is Darwin (macOS).
# Updated 2019-09-23.
_koopa_assert_is_darwin() {
    if ! _koopa_is_darwin
    then
        >&2 printf "Error: macOS (Darwin) is required.\n"
        return 1
    fi
    return 0
}



# FIXME Vectorize this.

# Assert that programs are installed.
#
# Supports checking of multiple programs in a single call.
#
# Updated 2019-09-23.
_koopa_assert_is_installed() {
    # FIXME Add a for loop here.
    if ! _koopa_is_installed "$1"
    then
        >&2 printf "Error: '%s' is not installed.\n" "$1"
        return 1
    fi
    return 0
}



# Assert that platform is Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux() {
    if ! _koopa_is_linux
    then
        >&2 printf "Error: Linux is required.\n"
        return 1
    fi
    return 0
}



# Assert that platform is Debian Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux_debian() {
    if ! _koopa_is_linux_debian
    then
        >&2 printf "Error: Debian is required.\n"
        return 1
    fi
    return 0
}



# Assert that platform is Fedora Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux_fedora() {
    if ! _koopa_is_linux_fedora
    then
        >&2 printf "Error: Fedora is required.\n"
        return 1
    fi
    return 0
}



# Assert that input does not exist on disk.
# Updated 2019-09-23.
_koopa_assert_is_non_existing() {
    if [ -e "$1" ]
    then
        >&2 printf "Error: Exists: '%s'\n" "$1"
        return 1
    fi
    return 0
}



# Assert that input is not a directory.
# Updated 2019-09-12.
_koopa_assert_is_not_dir() {
    _koopa_assert_is_existing "$1"
    if [ -d "$1" ]
    then
        >&2 printf "Error: Directory exists: '%s'\n" "$1"
        return 1
    fi
    return 0
}



# FIXME Add these:
# _koopa_assert_is_executable
# _koopa_assert_is_not_file
# _koopa_assert_is_not_symlink
# _koopa_assert_is_readable
# _koopa_assert_is_symlink
# _koopa_assert_is_writable
