#!/usr/bin/env zsh

# Update pure prompt scripts.
# Modified 2019-06-18.

# See also:
# - https://github.com/sindresorhus/pure

koopa_fpath="${KOOPA_HOME}/system/extra/zsh/fpath"
if [[ ! -d "$koopa_fpath" ]]
then
    >&2 printf "fpath directory is missing.\n%s\n" "$koopa_fpath"
    exit 1
fi

url_stem="https://raw.githubusercontent.com/sindresorhus/pure/master"

pure_file="${koopa_fpath}/prompt_pure_setup"
rm "$pure_file"
wget -O "$pure_file" "${url_stem}/pure.zsh"
chmod +x "$pure_file"

async_file="${koopa_fpath}/async"
rm "$async_file"
wget -O "$async_file" "${url_stem}/async.zsh"
chmod +x "$async_file"

printf "Pure prompt scripts updated successfully.\n"
