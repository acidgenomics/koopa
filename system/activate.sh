#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC2236



# Activate koopa in the current shell.

ACTIVATE_DIR="${KOOPA_SYSTEM_DIR}/activate"

# Set internal variable to check if koopa is already active.
[ ! -z "$KOOPA_PLATFORM" ] && KOOPA_ACTIVATED=1

# Run pre-flight checks to ensure platform is supported.
if [ -z "$KOOPA_ACTIVATED" ]
then
    PREFLIGHT_DIR="${ACTIVATE_DIR}/preflight"
    . "${PREFLIGHT_DIR}/bash-version.sh"
    . "${PREFLIGHT_DIR}/python-version.sh"
    . "${PREFLIGHT_DIR}/platform.sh"
    unset -v PREFLIGHT_DIR
fi



# ======================================
# Base shell configuration
# ======================================

BASE_DIR="${ACTIVATE_DIR}/base"

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
    EXTRA_DIR="${ACTIVATE_DIR}/extra"

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
        ZSH_DIR="$EXTRA_DIR/zsh"
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
        . "${DARWIN_DIR}/perlbrew.sh"
        . "${DARWIN_DIR}/rbenv.sh"
        unset -v DARWIN_DIR
    fi

    # Set up the today bucket.
    bash today-bucket.sh

    unset -v EXTRA_DIR
fi



unset -v ACTIVATE_DIR KOOPA_ACTIVATED
