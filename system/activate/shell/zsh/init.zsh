#!/usr/bin/env zsh

# Initialize ZSH.
# Updated 2019-10-31.

koopa_fpath="${KOOPA_PREFIX}/shell/zsh/functions"
if [[ ! -d "$koopa_fpath" ]]
then
    _koopa_warning "fpath directory is missing: '${koopa_fpath}'."
    return 1
fi
_koopa_force_add_to_fpath_start "$koopa_fpath"
unset -v koopa_fpath

# > autoload -U compaudit compinit
autoload -U colors && colors
