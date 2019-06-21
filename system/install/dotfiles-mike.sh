#!/usr/bin/env bash
set -Eeu -o pipefail

# Mike-specific dot files.
# Modified 2019-06-21.

private_dir="${KOOPA_CONFIG_DIR}/dotfiles-private"
if [[ ! -d "$private_dir" ]]
then
    git clone git@github.com:mjsteinbaugh/dotfiles-private.git "$private_dir"
fi
unset -v private_dir

if [[ "$KOOPA_OS_NAME" == "darwin" ]]
then
    dotfile --force os/darwin/gitconfig
else
    dotfile --force gitconfig
fi

dotfile --force --private Rsecrets
dotfile --force --private secrets
dotfile --force --private travis
dotfile --force Rprofile
dotfile --force forward
