#!/usr/bin/env zsh

# Set ZSH functions path.
# Updated 2019-08-17.

koopa_fpath="${KOOPA_HOME}/shell/zsh/site-functions"
if [[ ! -d "$koopa_fpath" ]]
then
    >&2 printf "Error: fpath directory is missing: '%s'.\n" "$koopa_fpath"
    return 1
fi
export FPATH="${koopa_fpath}:${FPATH}"
unset -v koopa_fpath
