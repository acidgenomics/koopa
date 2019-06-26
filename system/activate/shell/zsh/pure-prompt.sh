#!/usr/bin/env zsh
# shellcheck disable=SC2039,SC2206

# Pure prompt.
# Modified 2019-06-18.

# See also:
# - https://github.com/sindresorhus/pure
# - https://github.com/sindresorhus/pure/wiki

# This won't work if an oh-my-zsh theme is enabled.
# This step must be sourced after oh-my-zsh.

# Quick install using node:
# > npm install --global pure-prompt
# Note that npm method requires write access into `/usr/local`.
# Let's configure manually instead, which also works on remote servers.

script_file="${(%):-%N}"
script_dir="$(cd "$(dirname "$script_file")" >/dev/null 2>&1 && pwd)"

koopa_fpath="${script_dir}/fpath"
if [[ ! -d "$koopa_fpath" ]]
then
    >&2 printf "Error: fpath directory is missing.\n%s\n" "$koopa_fpath"
    return 1
fi
export FPATH="${koopa_fpath}:${FPATH}"

autoload -U promptinit
promptinit
prompt pure

unset -v koopa_fpath script_dir script_file
