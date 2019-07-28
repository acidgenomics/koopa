#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# Install dot files.
# Updated 2019-06-23.

dotfile --force Rprofile
dotfile --force bash_profile
dotfile --force bashrc
dotfile --force kshrc
dotfile --force shrc
dotfile --force zshrc

host_type="$(koopa host-type)"
os_type="$(koopa os-type)"

# R
if [[ "$os_type" == "darwin" ]]
then
    dotfile --force os/darwin/R
    dotfile --force os/darwin/Renviron
elif [[ "$host_type" == "harvard-o2" ]]
then
    dotfile --force host/harvard-o2/Renviron
elif [[ "$host_type" == "harvard-odyssey" ]]
then
    dotfile --force host/harvard-odyssey/Renviron
elif _koopa_is_linux && [[ -z "${shared:-}" ]]
then
    dotfile --force os/linux/Renviron
fi

unset -v host_type os_type
