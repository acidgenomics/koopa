#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC2236

# Activate koopa in the current shell.



# Set internal variable to check if koopa is already active.
[ ! -z "$KOOPA_PLATFORM" ] && KOOPA_ACTIVATED=1



# Run pre-flight checks to ensure platform is supported.
if [ -z "$KOOPA_ACTIVATED" ]
then
    . "${KOOPA_SYSTEM_DIR}/activate/preflight/01-bash-version.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/preflight/02-python-version.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/preflight/03-platform.sh"
fi



# Always load these non-persistent settings.
. "${KOOPA_SYSTEM_DIR}/activate/base/secrets.sh"
. "${KOOPA_SYSTEM_DIR}/activate/base/functions.sh"
. "${KOOPA_SYSTEM_DIR}/activate/base/aliases.sh"
. "${KOOPA_SYSTEM_DIR}/activate/base/set.sh"
. "${KOOPA_SYSTEM_DIR}/activate/base/ssh-key.sh"



# Skip these persistent settings in subshells (e.g. tmux).
if [ -z "$KOOPA_ACTIVATED" ]
then
    . "${KOOPA_SYSTEM_DIR}/activate/base/exports/general.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/base/exports/cpu-count.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/base/exports/genomes.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/base/exports/path.sh"
    
    . "${KOOPA_SYSTEM_DIR}/activate/base/programs/aspera.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/base/programs/bcbio.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/base/programs/conda.sh"
fi



# Shell-specific configuration.
if [ "$KOOPA_SHELL" = "bash" ]
then
    . "${KOOPA_SYSTEM_DIR}/activate/bash/init.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/bash/shopt.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/bash/bind.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/bash/ps1.sh"
elif [ "$KOOPA_SHELL" = "ksh" ]
then
    . "${KOOPA_SYSTEM_DIR}/activate/ksh/init.sh"
elif [ "$KOOPA_SHELL" = "zsh" ]
then
    . "${KOOPA_SYSTEM_DIR}/activate/zsh/init.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/zsh/oh-my-zsh.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/zsh/pure-prompt.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/zsh/setopt.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/zsh/bindkey.sh"
fi



# Platform-specific configuration.
if [ ! -z "$MACOS" ]
then
    if [ -z "$KOOPA_ACTIVATED"]
    then
        . "${KOOPA_SYSTEM_DIR}/activate/darwin/exports.sh"
        . "${KOOPA_SYSTEM_DIR}/activate/darwin/homebrew.sh"
    fi
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/aliases.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/grc-colors.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/perlbrew.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/rbenv.sh"
fi



unset -v KOOPA_ACTIVATED
