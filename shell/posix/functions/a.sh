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



# Convert a bash array to an R vector string.
# Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
# Updated 2019-09-25.
_koopa_array_to_r_vector() {
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}



# Assert that input contains a file extension.
# Updated 2019-09-26
_koopa_assert_has_file_ext() {
    if ! echo "$1" | grep -q "\."
    then
        >&2 printf "Error: No file extension: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that conda and Python virtual environments aren't active.
# Updated 2019-09-12.
_koopa_assert_has_no_environments() {
    if ! _koopa_has_no_environments
    then
        >&2 printf "Error: Active environment detected.\n"
        exit 1
    fi
    return 0
}



# Assert that current user has sudo (admin) permissions.
# Updated 2019-09-12.
_koopa_assert_has_sudo() {
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        exit 1
    fi
    return 0
}



# Assert that platform is Darwin (macOS).
# Updated 2019-09-23.
_koopa_assert_is_darwin() {
    if ! _koopa_is_darwin
    then
        >&2 printf "Error: macOS (Darwin) is required.\n"
        exit 1
    fi
    return 0
}



# Assert that input is a directory.
# Updated 2019-09-12.
_koopa_assert_is_dir() {
    if [ ! -d "$1" ]
    then
        >&2 printf "Error: Not a directory: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is executable.
# Updated 2019-09-24.
_koopa_assert_is_executable() {
    if [ ! -x "$1" ]
    then
        >&2 printf "Error: Not executable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input exists on disk.
#
# Note that '-e' flag returns true for file, dir, or symlink.
#
# Updated 2019-09-24.
_koopa_assert_is_existing() {
    if [ ! -e "$1" ]
    then
        >&2 printf "Error: Does not exist: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is a file.
# Updated 2019-09-12.
_koopa_assert_is_file() {
    if [ ! -f "$1" ]
    then
        >&2 printf "Error: Not a file: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input matches a specified file type.
#
# Example: _koopa_assert_is_file_type "$x" "csv"
#
# Updated 2019-09-24.
_koopa_assert_is_file_type() {
    _koopa_assert_is_file "$1"
    _koopa_assert_matches_pattern "$1" "\.${2}\$"
}



# Assert that programs are installed.
#
# Supports checking of multiple programs in a single call.
# Note that '_koopa_is_installed' is not vectorized.
#
# Updated 2019-09-24.
_koopa_assert_is_installed() {
    for arg in "$@"
    do
        if ! _koopa_is_installed "$arg"
        then
            >&2 printf "Error: '%s' is not installed.\n" "$arg"
            exit 1
        fi
    done
    return 0
}



# Assert that platform is Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux() {
    if ! _koopa_is_linux
    then
        >&2 printf "Error: Linux is required.\n"
        exit 1
    fi
    return 0
}



# Assert that platform is Debian Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux_debian() {
    if ! _koopa_is_linux_debian
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
    return 0
}



# Assert that platform is Fedora Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux_fedora() {
    if ! _koopa_is_linux_fedora
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
    return 0
}



# Assert that input does not exist on disk.
# Updated 2019-09-23.
_koopa_assert_is_non_existing() {
    if [ -e "$1" ]
    then
        >&2 printf "Error: Exists: '%s'\n" "$1"
        exit 1
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
        exit 1
    fi
    return 0
}



# Assert that input is not a file.
# Updated 2019-09-24.
_koopa_assert_is_not_file() {
    if [ -f "$1" ]
    then
        >&2 printf "Error: Is file: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is not a symbolic link.
# Updated 2019-09-24.
_koopa_assert_is_not_symlink() {
    if [ -L "$1" ]
    then
        >&2 printf "Error: Is symlink: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is readable.
# Updated 2019-09-24.
_koopa_assert_is_readable() {
    if [ ! -r "$1" ]
    then
        >&2 printf "Error: Not readable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is a symbolic link.
# Updated 2019-09-24.
_koopa_assert_is_symlink() {
    if [ ! -L "$1" ]
    then
        >&2 printf "Error: Is symlink: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is writable.
# Updated 2019-09-24.
_koopa_assert_is_writable() {
    if [ ! -r "$1" ]
    then
        >&2 printf "Error: Not writable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input matches a pattern.
#
# Bash alternative:
# > [[ ! $1 =~ $2 ]]
#
# Updated 2019-09-24.
_koopa_assert_matches_pattern() {
    if ! echo "$1" | grep -q "$2"
    then
        >&2 printf "Error: '%s' does not match pattern '%s'.\n" "$1" "$2"
        exit 1
    fi
    return 0
}
