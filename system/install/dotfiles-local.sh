#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# Install dot files.
# Modified 2019-06-23.

dotfile --force Rprofile
dotfile --force bash_profile
dotfile --force bashrc
dotfile --force kshrc
dotfile --force shrc
dotfile --force zshrc

host_name="$(koopa host-name)"
os_name="$(koopa os-name)"

# R
if [[ "${os_name:-}" == "darwin" ]]
then
    dotfile --force os/darwin/R
    dotfile --force os/darwin/Renviron
elif [[ "${host_name:-}" == "harvard-o2" ]]
then
    dotfile --force host/harvard-o2/Renviron
elif [[ "${host_name:-}" == "harvard-odyssey" ]]
then
    dotfile --force host/harvard-odyssey/Renviron
elif _koopa_is_linux && [[ -z "${shared:-}" ]]
then
    dotfile --force os/linux/Renviron
fi

unset -v host_name os_name
