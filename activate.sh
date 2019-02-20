#!/bin/sh
# shellcheck disable=SC1090,SC2236
# SC2236: zsh doesn't handle `-n` flag in place of `! -z` correctly in POSIX
# mode when using `[` instead of `[[`.



# koopa shell bootloader
# (c) 2018 Michael Steinbaugh
# This software is provided under an MIT License.
# Currently supporting POSIX-compliant shells: bash, ksh, zsh.

export KOOPA_VERSION="0.3.0"
export KOOPA_DATE="2019-02-20"



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
    echo "Note that /bin/sh is not recommended."
    echo ""
    echo "$SHELL"
    echo "$0"
    echo "$-"
    echo ""
    env | sort
    return 1
fi
export KOOPA_SHELL



# Locate the koopa installation based on the source operation.
if [ "$KOOPA_SHELL" = "bash" ]
then
    # SC2039: In POSIX sh, array references are undefined.
    # shellcheck disable=SC2039
    KOOPA_SOURCE="${BASH_SOURCE[0]}"
elif [ "$KOOPA_SHELL" = "ksh" ]
then
    # SC2154: .sh.file is referenced but not assigned.
    # shellcheck disable=SC2154
    KOOPA_SOURCE="${.sh.file}"
elif [ "$KOOPA_SHELL" = "zsh" ]
then
    KOOPA_SOURCE="$0"
fi

KOOPA_BASE_DIR="$( dirname "$KOOPA_SOURCE" )"
export KOOPA_BASE_DIR

KOOPA_BIN_DIR="${KOOPA_BASE_DIR}/bin"
export KOOPA_BIN_DIR

KOOPA_SYSTEM_DIR="${KOOPA_BASE_DIR}/system"



# Export `$KOOPA_EXTRA` when we're loading the extra shell config scripts.
# SC2154: extra is reference but not assigned.
# shellcheck disable=SC2154
if [ ! -z "$extra" ]
then
    KOOPA_EXTRA=1
    export KOOPA_EXTRA
    unset -v extra
fi



# Set internal variable to check if koopa is already active.
[ ! -z "$KOOPA_PLATFORM" ] && KOOPA_ACTIVATED=1



# ======================================
# Pre-flight checks
# ======================================

if [ -z "$KOOPA_ACTIVATED" ]
then
    PRE_DIR="${KOOPA_SYSTEM_DIR}/pre"
    . "${PRE_DIR}/bash-version.sh"
    . "${PRE_DIR}/python-version.sh"
    . "${PRE_DIR}/platform.sh"
    unset -v PRE_DIR
fi



# ======================================
# Base shell configuration
# ======================================

BASE_DIR="${KOOPA_SYSTEM_DIR}/base"

# Always load these non-persistent settings.
. "${BASE_DIR}/secrets.sh"
. "${BASE_DIR}/functions.sh"
. "${BASE_DIR}/aliases.sh"
. "${BASE_DIR}/set.sh"
. "${BASE_DIR}/ssh-key.sh"

# Skip these persistent settings in subshells (e.g. tmux).
if [ -z "$KOOPA_ACTIVATED" ]
then
    EXPORTS_DIR="${BASE_DIR}/exports"
    . "${EXPORTS_DIR}/general.sh"
    . "${EXPORTS_DIR}/cpu-count.sh"
    . "${EXPORTS_DIR}/genomes.sh"
    . "${EXPORTS_DIR}/path.sh"
    unset -v EXPORTS_DIR

    PROGRAMS_DIR="${BASE_DIR}/programs"
    . "${PROGRAMS_DIR}/perlbrew.sh"
    . "${PROGRAMS_DIR}/aspera.sh"
    . "${PROGRAMS_DIR}/bcbio.sh"
    . "${PROGRAMS_DIR}/conda.sh"
    unset -v PROGRAMS_DIR
fi

unset -v BASE_DIR



# ======================================
# Extra shell configuration
# ======================================

if [ ! -z "$KOOPA_EXTRA" ]
then
    EXTRA_DIR="${KOOPA_SYSTEM_DIR}/extra"

    # Set default file permissions.
    . "${EXTRA_DIR}/umask.sh"

    # Shell-specific configuration.
    if [ "$KOOPA_SHELL" = "bash" ]
    then
        BASH_DIR="${EXTRA_DIR}/bash"
        . "${BASH_DIR}/init.sh"
        . "${BASH_DIR}/shopt.sh"
        . "${BASH_DIR}/bind.sh"
        . "${BASH_DIR}/ps1.sh"
        unset -v BASH_DIR
    elif [ "$KOOPA_SHELL" = "ksh" ]
    then
        KSH_DIR="${EXTRA_DIR}/ksh"
        . "${KSH_DIR}/init.sh"
        unset -v KSH_DIR
    elif [ "$KOOPA_SHELL" = "zsh" ]
    then
        ZSH_DIR="${EXTRA_DIR}/zsh"
        . "${ZSH_DIR}/init.sh"
        . "${ZSH_DIR}/oh-my-zsh.sh"
        . "${ZSH_DIR}/pure-prompt.sh"
        . "${ZSH_DIR}/setopt.sh"
        . "${ZSH_DIR}/bindkey.sh"
        unset -v ZSH_DIR
    fi

    # Platform-specific configuration.
    if [ ! -z "$MACOS" ]
    then
        DARWIN_DIR="${EXTRA_DIR}/darwin"
        if [ -z "$KOOPA_ACTIVATED" ]
        then
            . "${DARWIN_DIR}/exports.sh"
            . "${DARWIN_DIR}/homebrew.sh"
        fi
        . "${DARWIN_DIR}/aliases.sh"
        . "${DARWIN_DIR}/grc-colors.sh"
        . "${DARWIN_DIR}/rbenv.sh"
        unset -v DARWIN_DIR
    fi

    # Set up the today bucket.
    bash today-bucket.sh

    unset -v EXTRA_DIR
fi



# =====================================
# Post-flight checks (cleanup)
# =====================================

. "${KOOPA_SYSTEM_DIR}/post/unset.sh"
