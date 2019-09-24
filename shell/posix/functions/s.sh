#!/bin/sh
# shellcheck disable=SC2039



# Note that this isn't necessarily the default shell (`$SHELL`).
# Updated 2019-06-27.
_koopa_shell() {
    local shell
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell="bash"
    elif [ -n "${KSH_VERSION:-}" ]
    then
        shell="ksh"
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell="zsh"
    else
        >&2 cat << EOF
Error: Failed to detect supported shell.
Supported: bash, ksh, zsh.

  SHELL: ${SHELL}
      0: ${0}
      -: ${-}
EOF
        return 1
    fi
    
    echo "$shell"
}



# Strip pattern from left side (start) of string.
#
# Usage: _koopa_lstrip "string" "pattern"
#
# Example: _koopa_lstrip "The Quick Brown Fox" "The "
#
# Updated 2019-09-22.
_koopa_strip_left() {
    printf '%s\n' "${1##$2}"
}



# Strip pattern from right side (end) of string.
#
# Usage: _koopa_rstrip "string" "pattern"
#
# Example: _koopa_rstrip "The Quick Brown Fox" " Fox"
#
# Updated 2019-09-22.
_koopa_strip_right() {
    printf '%s\n' "${1%%$2}"
}



# Strip trailing slash in file path string.
#
# Alternate approach using sed:
# > sed 's/\/$//' <<< "$1"
#
# Updated 2019-09-24.
_koopa_strip_trailing_slash() {
    _koopa_strip_right "$1" "/"
}
