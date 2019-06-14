#!/usr/bin/env zsh
# shellcheck disable=SC2039,SC2206

# Pure prompt
#
# This won't work if an oh-my-zsh theme is enabled.
# This step must be sourced after oh-my-zsh.
#
# See also:
# - https://github.com/sindresorhus/pure
# - https://github.com/sindresorhus/pure/wiki
#
# Quick install using node:
# npm install --global pure-prompt
# Note that npm method requires write access into /usr/local (elevated).
# Let's configure manually instead, which also works on remote servers.

script_file="${(%):-%N}"
script_dir="$(cd "$(dirname "$script_file")" >/dev/null 2>&1 && pwd)"

koopa_fpath="${script_dir}/fpath"
if [[ ! -d "$koopa_fpath" ]]
then
    >&2 echo "Error: fpath directory is missing."
    return 1
fi
export FPATH="${koopa_fpath}:${FPATH}"

autoload -U promptinit
promptinit
prompt pure

unset -v koopa_fpath script_dir script_file
