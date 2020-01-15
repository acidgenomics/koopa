#!/usr/bin/env zsh

# Initialize Zsh.
# Updated 2020-01-15.

# Note on path (and also fpath) arrays in Zsh:
# https://www.zsh.org/mla/users/2012/msg00785.html
#
# At startup, zsh ties the array variable '$path' to the environment string
# '$PATH'. If you run:
# 
#    print "${path[@]}"
#    print "$PATH"
#
# You should see strings that are identical except that the first one has
# spaces, where the second has colons.
#
# (If instead you see only the first element of '$PATH' when printing '$path',
# you have the ksharrays option set, and must use '${path[@]}' instead.)

# What's the difference between 'autoload' and 'autoload -U'?
# https://unix.stackexchange.com/questions/214296
# https://stackoverflow.com/questions/30840651/what-does-autoload-do-in-zsh

koopa_fpath="${KOOPA_PREFIX}/shell/zsh/functions"
if [[ ! -d "$koopa_fpath" ]]
then
    _koopa_warning "FPATH directory is missing: '${koopa_fpath}'."
    return 1
fi
_koopa_force_add_to_fpath_start "$koopa_fpath"
unset -v koopa_fpath

# Enable colors in terminal.
autoload -Uz colors && colors

# Enable completion system.
# Suppressing warning for KOOPA_TEST mode:
# compinit:141: parse error: condition expected: $1
autoload -Uz compinit && compinit 2>/dev/null

# compinit warn about directories with group write access.
# Here's an alias that will quickly fix this issue.
alias zsh-compaudit-fix="compaudit | xargs sudo chmod g-w"
