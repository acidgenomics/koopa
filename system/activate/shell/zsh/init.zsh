#!/usr/bin/env zsh

# Initialize ZSH.
# Updated 2019-10-31.

koopa_fpath="${KOOPA_HOME}/shell/zsh/functions"
if [[ ! -d "$koopa_fpath" ]]
then
    _acid_warning "fpath directory is missing: '${koopa_fpath}'."
    return 1
fi
_acid_force_add_to_fpath_start "$koopa_fpath"
unset -v koopa_fpath

# > autoload -U compaudit compinit
autoload -U colors && colors
