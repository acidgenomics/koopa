#!/bin/sh

# Perlbrew
# https://perlbrew.pl
# Modified 2019-06-14.

# Check for bash or zsh.
if [ "$KOOPA_SHELL" != "bash" ] && [ "$KOOPA_SHELL" != "zsh" ]
then
    return 0
fi

# Check for installation, otherwise early return.
if [ ! -z "${PERLBREW_ROOT:-}" ]
then
    prefix="$PERLBREW_ROOT"
elif [ -d "${HOME}/perl5/perlbrew" ]
then
    prefix="${HOME}/perl5/perlbrew"
elif [ -d "/usr/local/perlbrew" ]
then
    prefix="/usr/local/perlbrew"
else
    return 0
fi

# Now ready to source bashrc activation script.
# Note that this is also compatible with zsh.
file="${prefix}/etc/bashrc"
# shellcheck disable=SC1090
[ -f "$file" ] && . "$file"

unset -v file prefix
