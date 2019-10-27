#!/usr/bin/env zsh

# Set ZSH functions path.
# Updated 2019-08-17.

koopa_fpath="${KOOPA_HOME}/shell/zsh/functions"
if [[ ! -d "$koopa_fpath" ]]
then
    _koopa_warning "fpath directory is missing: '${koopa_fpath}'."
    return 1
fi
_koopa_force_add_to_fpath_start "$koopa_fpath"
unset -v koopa_fpath
