#!/usr/bin/env bash

# Clone Acid Genomics Docker image recipes.
# Updated 2019-07-28.

target_dir="$(_koopa_config_dir)/docker"
if [[ ! -d "$target_dir" ]]
then
    git clone --recursive git@github.com:acidgenomics/docker.git "$target_dir"
fi
unset -v target_dir
