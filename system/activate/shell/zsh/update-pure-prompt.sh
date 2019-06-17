#!/usr/bin/env zsh

# Update pure prompt scripts
# https://github.com/sindresorhus/pure

koopa_fpath="${KOOPA_DIR}/system/extra/zsh/fpath"
if [[ ! -d "$koopa_fpath" ]]
then
    echo "fpath directory is missing."
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

echo "Pure prompt scripts updated successfully."
