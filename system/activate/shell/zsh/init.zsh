#!/usr/bin/env zsh

# Initialize ZSH.
# Updated 2019-12-14.

koopa_fpath="${KOOPA_PREFIX}/shell/zsh/functions"
if [[ ! -d "$koopa_fpath" ]]
then
    _koopa_warning "fpath directory is missing: '${koopa_fpath}'."
    return 1
fi
_koopa_force_add_to_fpath_start "$koopa_fpath"
unset -v koopa_fpath

# compinit will warn about directories with group write access.
alias zsh-compaudit-fix="compaudit | xargs sudo chmod g-w"

# > autoload -U compaudit compinit
autoload -U colors && colors
