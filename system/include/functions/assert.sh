#!/bin/sh

# Assertive check functions
# Modified 2019-06-27.


# Modified 2019-06-27.
_koopa_assert_has_no_environments() {
    if ! _koopa_has_no_environments
    then
        >&2 printf "Error: active environment detected.\n"
        exit 1
    fi
}



# Modified 2019-06-27.
_koopa_assert_has_sudo() {
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        exit 1
    fi
}



# Modified 2019-06-27.
_koopa_assert_is_darwin() {
    if ! _koopa_is_darwin
    then
        >&2 printf "Error: macOS is required.\n"
        exit 1
    fi
}



# Modified 2019-06-27.
_koopa_assert_is_installed() {
    local program
    program="$1"
    if ! _koopa_is_installed "$program"
    then
        >&2 printf "Error: %s is not installed.\n" "$program"
        return 1
    fi
}



# Modified 2019-06-27.
_koopa_assert_is_linux() {
    if ! _koopa_is_linux
    then
        >&2 printf "Error: Linux is required.\n"
        exit 1
    fi
}



# Modified 2019-06-24.
_koopa_assert_is_linux_debian() {
    if ! _koopa_is_linux_debian
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
}



# Modified 2019-06-24.
_koopa_assert_is_linux_fedora() {
    if ! _koopa_is_linux_fedora
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
}



# Check if directory already exists.
# Modified 2019-06-27.
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



# Detect activation of virtual environments.
# Modified 2019-06-25.
_koopa_has_no_environments() {
    [ -x "$(command -v conda)" ] && [ ! -z "${CONDA_PREFIX:-}" ] && return 1
    [ -x "$(command -v deactivate)" ] && return 1
    return 0
}



# Administrator (sudo) permission.
# Currently performing a simple check by verifying wheel group.
# - Darwin (macOS): admin
# - Debian: sudo
# - Fedora: wheel
# Modified 2019-06-19.
_koopa_has_sudo() {
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}



# Modified 2019-06-22.
_koopa_is_darwin() {
    [ "$(uname -s)" = "Darwin" ]
}



# Modified 2019-06-21.
_koopa_is_interactive() {
    echo "$-" | grep -q "i"
}



# Modified 2019-06-27.
_koopa_is_installed() {
    local program
    program="$1"
    _koopa_quiet_which "$program"
}



# Modified 2019-06-21.
_koopa_is_linux() {
    [ "$(uname -s)" = "Linux" ]
}



# Modified 2019-06-24.
_koopa_is_linux_debian() {
    [ -f /etc/os-release ] || return 1
    grep "ID="      /etc/os-release | grep -q "debian" ||
    grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}



# Modified 2019-06-24.
_koopa_is_linux_fedora() {
    [ -f /etc/os-release ] || return 1
    grep "ID="      /etc/os-release | grep -q "fedora" ||
    grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}



# Modified 2019-06-21.
_koopa_is_login_bash() {
    [ "$0" = "-bash" ]
}



# Modified 2019-06-21.
_koopa_is_login_zsh() {
    [ "$0" = "-zsh" ]
}
