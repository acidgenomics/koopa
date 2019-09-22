#!/bin/sh
# shellcheck disable=SC2039



# Add both `bin/` and `sbin/` to PATH.
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
# Updated 2019-09-12.
_koopa_add_config_link() {
    local config_dir
    config_dir="$(_koopa_config_dir)"
    
    local source_file
    source_file="$1"
    if [ ! -x "$source_file" ]
    then
        >&2 printf "Error: Does not exist: %s\n" "$source_file"
        return 1
    fi
    source_file="$(realpath "$source_file")"
    
    local dest_name
    dest_name="$2"
    
    local dest_file
    dest_file="${config_dir}/${dest_name}"
    
    rm -fv "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
}



# Updated 2019-09-12.
_koopa_add_to_path_end() {
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${PATH}:${1}"
}



# Updated 2019-09-12.
_koopa_add_to_path_start() {
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${1}:${PATH}"
}



# Updated 2019-09-12.
_koopa_assert_has_no_environments() {
    if ! _koopa_has_no_environments
    then
        >&2 printf "Error: active environment detected.\n"
        return 1
    fi
    return 0
}



# Updated 2019-09-12.
_koopa_assert_has_sudo() {
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        return 1
    fi
    return 0
}



# Updated 2019-09-12.
_koopa_assert_is_dir() {
    if [ ! -d "$1" ]
    then
        >&2 printf "Error: Not a directory: '%s'\n" "$1"
        return 1
    fi
    return 0
}



# Updated 2019-09-22.
_koopa_assert_is_dir_or_file() {
    if [ ! -d "$1" ] || [ -f "$1" ]
    then
        >&2 printf "Error: Not a directory or file: '%s'\n" "$1"
        return 1
    fi
    return 0
}



# Updated 2019-09-12.
_koopa_assert_is_file() {
    if [ ! -f "$1" ]
    then
        >&2 printf "Error: Not a file: '%s'\n" "$1"
        return 1
    fi
    return 0
}


# Updated 2019-09-12.
_koopa_assert_is_darwin() {
    if ! _koopa_is_darwin
    then
        >&2 printf "Error: macOS is required.\n"
        return 1
    fi
    return 0
}



# Updated 2019-09-12.
_koopa_assert_is_installed() {
    if ! _koopa_is_installed "$1"
    then
        >&2 printf "Error: '%s' is not installed.\n" "$1"
        return 1
    fi
    return 0
}



# Updated 2019-09-12.
_koopa_assert_is_linux() {
    if ! _koopa_is_linux
    then
        >&2 printf "Error: Linux is required.\n"
        return 1
    fi
    return 0
}



# Updated 2019-09-12.
_koopa_assert_is_linux_debian() {
    if ! _koopa_is_linux_debian
    then
        >&2 printf "Error: Debian is required.\n"
        return 1
    fi
    return 0
}



# Updated 2019-09-12.
_koopa_assert_is_linux_fedora() {
    if ! _koopa_is_linux_fedora
    then
        >&2 printf "Error: Fedora is required.\n"
        return 1
    fi
    return 0
}



# Check if directory already exists.
# Updated 2019-09-12.
_koopa_assert_is_not_dir() {
    if [ -d "$1" ]
    then
        >&2 printf "Error: Directory exists: '%s'\n" "$1"
        return 1
    fi
    return 0
}
