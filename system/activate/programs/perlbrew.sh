#!/bin/sh

# Perlbrew
# Modified 2019-06-26.

# See also:
# - https://perlbrew.pl

# Only attempt to autoload for bash or zsh.
echo "$(koopa shell)" | grep -Eq "^(bash|zsh)$" || return

# Check for installation, otherwise early return.
if [ -z "${PERLBREW_ROOT:-}" ]
then
    if [ -d "${HOME}/perl5/perlbrew" ]
    then
        PERLBREW_ROOT="${HOME}/perl5/perlbrew"
    elif [ -d "/usr/local/perlbrew" ]
    then
        PERLBREW_ROOT="/usr/local/perlbrew"
    else
        PERLBREW_ROOT=
    fi
fi

# Source the activation script, if accessible.
if [ -d "$PERLBREW_ROOT" ]
then
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "${PERLBREW_ROOT}/etc/bashrc"
else
    unset -v PERLBREW_ROOT
fi
