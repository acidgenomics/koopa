#!/bin/sh

# Perlbrew
# https://perlbrew.pl

# Installation instructions
# https://metacpan.org/pod/App::perlbrew
# https://github.com/gugod/App-perlbrew/wiki/Perlbrew-In-Shell-Scripts

# To install, run:
# curl -L https://install.perlbrew.pl | bash



# Check for installation, otherwise early return.
[ -z "${PERLBREW_ROOT:-}" ] && PERLBREW_ROOT="${HOME}/perl5/perlbrew"
[ ! -d "$PERLBREW_ROOT" ] && return 0
export PERLBREW_ROOT

# [ -z "$PERLBREW_HOME" ] && PERLBREW_HOME="${HOME}/.perlbrew"
# [ ! -d "$PERLBREW_HOME" ] && return 0
# export PERLBREW_HOME



# Check for bash or zsh, otherwise return with warning.
if [ "$KOOPA_SHELL" != "bash" ] && [ "$KOOPA_SHELL" != "zsh" ]
then
    printf "Perlbrew is only compatible with bash or zsh.\n"
    return 1
fi



# Now ready to source bashrc activation script.
# Note that this also works with zsh.
file="${PERLBREW_ROOT}/etc/bashrc"
# shellcheck disable=SC1090
[ -f "$file" ] && . "$file"
unset -v file
