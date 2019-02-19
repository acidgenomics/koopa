#!/bin/sh
# shellcheck disable=SC2236

# SC2236: zsh doesn't handle `-n` flag in place of `! -z` correctly in POSIX
# mode when using `[` instead of `[[`.



# koopa shell bootloader
# (c) 2018 Michael Steinbaugh
# This software is provided under an MIT License.
# Currently only supporting POSIX-compliant shells: bash, zsh.



# Detect the current shell.
# This is not necessarily the default shell (`$SHELL`).
if [ ! -z "$BASH_VERSION" ]
then
    KOOPA_SHELL="bash"
elif [ ! -z "$KSH_VERSION" ]
then
    KOOPA_SHELL="ksh"
elif [ ! -z "$ZSH_VERSION" ]
then
    KOOPA_SHELL="zsh"
else
    echo "koopa currently supports bash, ksh, or zsh shell."
    echo "Check your configuration."
    return 1
fi
export KOOPA_SHELL



# Locate the koopa installation based on the source operation.
if [ "$KOOPA_SHELL" = "bash" ]
then
    # SC2039: In POSIX sh, array references are undefined.
    # shellcheck disable=SC2039
    KOOPA_EXE="${BASH_SOURCE[0]}"
elif [ "$KOOPA_SHELL" = "ksh" ]
then
    # SC2154: .sh.file is referenced but not assigned.
    # shellcheck disable=SC2154
    KOOPA_EXE="${.sh.file}"
elif [ "$KOOPA_SHELL" = "zsh" ]
then
    KOOPA_EXE="$0"
fi
export KOOPA_EXE

# Future shell support:
# fish: `status -f`
# dash: doesn't seem to be possible.
# https://unix.stackexchange.com/questions/4650
# https://stackoverflow.com/questions/32981333



KOOPA_BIN_DIR="$( dirname "$KOOPA_EXE" )"
export KOOPA_BIN_DIR

KOOPA_BASE_DIR="$( dirname "$KOOPA_BIN_DIR" )"
export KOOPA_BASE_DIR

KOOPA_FUNCTIONS_DIR="${KOOPA_BASE_DIR}/functions"
export KOOPA_FUNCTIONS_DIR

KOOPA_SYSTEM_DIR="${KOOPA_BASE_DIR}/system"
export KOOPA_SYSTEM_DIR



# Note that we're allowing positional argument using `$1` but this isn't
# supported in all POSIX-compliant shells.
# SC2240 The dot command does not support arguments in sh/dash.
# Set them as variables.
[ -z "$cmd" ] && cmd="$1"
if [ "$cmd" = "activate" ]
then
    # shellcheck source=/dev/null
    . "${KOOPA_SYSTEM_DIR}/activate.sh"
elif [ "$cmd" = "info" ]
then
    # shellcheck source=/dev/null
    bash "${KOOPA_SYSTEM_DIR}/info.sh"
elif [ "$cmd" = "list" ]
then
    # shellcheck source=/dev/null
    . "${KOOPA_SYSTEM_DIR}/list.sh"
else
    echo "koopa args: activate, info, list"
    exit 1
fi
unset -v cmd
