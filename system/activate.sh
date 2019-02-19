#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC2236

# Activate koopa in the current shell.



# Set internal variable to check if koopa is already active.
[ ! -z "$KOOPA_PLATFORM" ] && ACTIVATED=1

# Set directory variables.
dir="${KOOPA_SYSTEM_DIR}/activate"
preflight="${dir}/preflight"
base="${dir}/base"
darwin="${dir}/darwin"
bash="${dir}/bash"
zsh="${dir}/zsh"
unset -v dir



# Run pre-flight checks to ensure platform is supported.
if [ -z "$ACTIVATED" ]
then
    . "${preflight}/01-bash-version.sh"
    . "${preflight}/02-python-version.sh"
    . "${preflight}/03-platform.sh"
fi



# Always load these non-persistent settings.
. "${base}/nonpersistent/secrets.sh"
. "${base}/nonpersistent/functions.sh"
. "${base}/nonpersistent/aliases.sh"
. "${base}/nonpersistent/ssh-key.sh"



# Skip these persistent settings in subshells (e.g. tmux).
if [ -z "$ACTIVATED" ]
then
    . "${base}/exports/general.sh"
    . "${base}/exports/cpu-count.sh"
    . "${base}/exports/genomes.sh"
    . "${base}/exports/path.sh"
    
    . "${base}/programs/aspera.sh"
    . "${base}/programs/bcbio.sh"
    . "${base}/programs/conda.sh"
fi



# Shell-specific configuration.
if [ "$KOOPA_SHELL" = "bash" ]
then
    . "${bash}/etc.sh"
    . "${bash}/shopt.sh"
    . "${bash}/bind.sh"
    . "${bash}/ps1.sh"
elif [ "$KOOPA_SHELL" = "zsh" ]
then
    . "${zsh}/oh-my-zsh.zsh"
    . "${zsh}/pure-prompt.zsh"
    . "${zsh}/setopt.zsh"
    . "${zsh}/bindkey.zsh"
fi



# Platform-specific configuration.
if [ ! -z "$MACOS" ]
then
    if [ -z "$activated"]
    then
        . "${darwin}/exports.sh"
        . "${darwin}/homebrew.sh"
    fi
    . "${darwin}/aliases.sh"
    . "${darwin}/grc-colors.sh"
    . "${darwin}/perlbrew.sh"
    . "${darwin}/rbenv.sh"
fi



unset -v base bash darwin preflight zsh
unset -v ACTIVATED
