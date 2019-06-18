#!/bin/sh

# Install dot files.
# Modified 2019-06-18.

os="${KOOPA_OS_NAME:-}"
host="${KOOPA_HOST_NAME:-}"

dotfile --force Rprofile
dotfile --force bash_profile
dotfile --force bashrc
dotfile --force kshrc
dotfile --force shrc
dotfile --force zshrc

# R
if [ "$os" = "darwin" ]
then
    dotfile --force os/darwin/R
    dotfile --force os/darwin/Renviron
elif [ "$host" = "harvard-o2" ]
then
    dotfile --force host/harvard-o2/Renviron
elif [ "$host" == "harvard-odyssey" ]
then
    dotfile --force host/harvard-odyssey/Renviron
elif [ ! -z "${LINUX:-}" ] && [ -z "${shared:-}" ]
then
    dotfile --force os/linux/Renviron
fi
