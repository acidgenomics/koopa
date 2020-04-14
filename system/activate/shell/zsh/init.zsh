#!/usr/bin/env zsh

# """
# Initialize Zsh.
# Updated 2020-04-13.
#
# Note on path (and also fpath) arrays in Zsh:
# https://www.zsh.org/mla/users/2012/msg00785.html
#
# At startup, zsh ties the array variable 'path' to the environment string
# 'PATH' (colon-delimited). If you see only the first element of 'PATH' when
# printing 'path', you have the ksharrays option set.
#
# What's the difference between 'autoload' and 'autoload -Uz'?
# https://unix.stackexchange.com/questions/214296
# https://stackoverflow.com/questions/30840651/what-does-autoload-do-in-zsh
# """

KOOPA_FPATH="${KOOPA_PREFIX}/shell/zsh/functions"
if [[ ! -d "$KOOPA_FPATH" ]]
then
    _koopa_warning "FPATH directory is missing: '${KOOPA_FPATH}'."
    return 1
fi
_koopa_force_add_to_fpath_start "$KOOPA_FPATH"
unset -v KOOPA_FPATH

# Enable colors in terminal.
autoload -Uz colors && colors

# Enable completion system.
# Suppressing warning for KOOPA_TEST mode:
# compinit:141: parse error: condition expected: $1
autoload -Uz compinit && compinit 2>/dev/null
