#!/bin/sh

# Assertive check functions
# Modified 2019-06-20.



_koopa_assert_has_no_environments() {
    # Ensure conda is deactivated.
    if [ -x "$(command -v conda)" ] && [ ! -z "${CONDA_PREFIX:-}" ]
    then
        >&2 printf "Error: conda is active.\n"
        exit 1
    fi

    # Ensure Python virtual environment is deactivated.
    if [ -x "$(command -v deactivate)" ]
    then
        >&2 printf "Error: Python virtualenv is active.\n"
        exit 1
    fi
}



_koopa_assert_has_sudo() {
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        exit 1
    fi
}



# Check if directory already exists.
# Modified 2019-06-19.
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



_koopa_assert_is_installed() {
    local program="$1"
    command -v "$program" >/dev/null 2>&1 || {
        >&2 printf "Error: %s is not installed.\n" "$program"
        return 1
    }
}



_koopa_assert_is_os_darwin() {
    if [ ! "$KOOPA_OS_NAME" = "darwin" ] || [ -z "${MACOS:-}" ]
    then
        >&2 printf "Error: macOS is required.\n"
        exit 1
    fi
}



_koopa_assert_is_os_debian() {
    if ! grep "ID="      /etc/os-release | grep -q "debian" &&
       ! grep "ID_LIKE=" /etc/os-release | grep -q "debian"
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
}



_koopa_assert_is_os_fedora() {
    if ! grep "ID="      /etc/os-release | grep -q "fedora" &&
       ! grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
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
