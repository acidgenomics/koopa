#!/usr/bin/env bash

# Mike-specific scripts.
# Updated 2019-07-27.

private_dir="$(_koopa_config_dir)/scripts-private"
if [[ ! -d "$private_dir" ]]
then
    git clone git@github.com:mjsteinbaugh/scripts-private.git "$private_dir"
fi
unset -v private_dir
