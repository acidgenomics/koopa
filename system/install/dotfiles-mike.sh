#!/usr/bin/env bash

# Mike-specific dot files.
# Updated 2019-06-23.

private_dir="$(_koopa_config_dir)/dotfiles-private"
if [[ ! -d "$private_dir" ]]
then
    git clone git@github.com:mjsteinbaugh/dotfiles-private.git "$private_dir"
fi
unset -v private_dir

if _koopa_is_darwin
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
