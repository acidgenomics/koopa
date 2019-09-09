#!/bin/sh
# shellcheck disable=SC2039



# Add both `bin/` and `sbin/` to PATH.
# Updated 2019-06-27.
_koopa_add_bins_to_path() {
    local relpath
    local prefix
    relpath="${1:-}"
    prefix="$KOOPA_HOME"
    [ -n "$relpath" ] && prefix="${prefix}/${relpath}"
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
}



# Updated 2019-06-27.
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
# Updated 2019-09-09.
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
    
    rm -f "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
}



# Updated 2019-06-27.
_koopa_add_to_path_end() {
    local dir
    dir="$1"
    [ ! -d "$dir" ] && return 0
    echo "$PATH" | grep -q "$dir" && return 0
    export PATH="${PATH}:${dir}"
}



# Updated 2019-06-27.
_koopa_add_to_path_start() {
    local dir
    dir="$1"
    [ ! -d "$dir" ] && return 0
    echo "$PATH" | grep -q "$dir" && return 0
    export PATH="${dir}:${PATH}"
}



# Updated 2019-06-27.
_koopa_assert_has_no_environments() {
    if ! _koopa_has_no_environments
    then
        >&2 printf "Error: active environment detected.\n"
        exit 1
    fi
}



# Updated 2019-06-27.
_koopa_assert_has_sudo() {
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        exit 1
    fi
}


# Updated 2019-06-27.
_koopa_assert_is_darwin() {
    if ! _koopa_is_darwin
    then
        >&2 printf "Error: macOS is required.\n"
        exit 1
    fi
}



# Updated 2019-06-27.
_koopa_assert_is_installed() {
    local program
    program="$1"
    if ! _koopa_is_installed "$program"
    then
        >&2 printf "Error: %s is not installed.\n" "$program"
        return 1
    fi
}



# Updated 2019-06-27.
_koopa_assert_is_linux() {
    if ! _koopa_is_linux
    then
        >&2 printf "Error: Linux is required.\n"
        exit 1
    fi
}



# Updated 2019-06-24.
_koopa_assert_is_linux_debian() {
    if ! _koopa_is_linux_debian
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
}



# Updated 2019-06-24.
_koopa_assert_is_linux_fedora() {
    if ! _koopa_is_linux_fedora
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
}



# Check if directory already exists.
# Updated 2019-06-27.
_koopa_assert_is_not_dir() {
    local path
    path="$1"
    # Error on existing installation.
    if [ -d "$path" ]
    then
        >&2 printf "Error: Directory already exists.\n%s\n" "$path"
        exit 1
    fi
}
