#!/bin/sh

# Enable more colors with grc.

file="$HOMEBREW_PREFIX/etc/grc.bashrc"
# shellcheck disable=SC1090
[ -f "$file" ] && "$file"
unset -v file
