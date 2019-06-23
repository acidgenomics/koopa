#!/bin/sh

# Perlbrew
# Modified 2019-06-21.

# See also:
# - https://perlbrew.pl

# Only attempt to autoload for bash or zsh.
echo "$(koopa shell)" | grep -Eq "^(bash|zsh)$" || return

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
