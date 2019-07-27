#!/bin/sh

# Enable more colors with grc.
# Updated 2019-06-26.

file="${HOMEBREW_PREFIX}/etc/grc.bashrc"
[ -f "$file" ] && "$file"
unset -v file
