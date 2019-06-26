#!/bin/sh

# Enable more colors with grc.
# Modified 2019-06-26.

file="${HOMEBREW_PREFIX}/etc/grc.bashrc"
[ -f "$file" ] && "$file"
unset -v file
