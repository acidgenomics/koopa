#!/usr/bin/env bash
set -Eeuo pipefail

# Vim
# https://github.com/vim/vim

sudo -v

# Install vim build dependencies, if necessary.
if [ -x "$(command -v yum)" ]
then
    sudo yum -y install yum-utils
    sudo yum-builddep -y vim
fi
