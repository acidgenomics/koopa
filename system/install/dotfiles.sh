#!/bin/sh

# Install dot files.
# Modified 2019-06-17.

# Never attempt to configure dotfiles for root.
[ "$(id -u)" -eq 0 ] && return 0

printf "\nConfiguring dotfiles.\n"

os="${KOOPA_OS_NAME:-}"
host="${KOOPA_HOST_NAME:-}"

dotfile --force Rprofile
dotfile --force bash_profile
dotfile --force bashrc
dotfile --force condarc
dotfile --force gitignore
dotfile --force kshrc
dotfile --force screenrc
dotfile --force shrc
dotfile --force spacemacs
dotfile --force tmux.conf
dotfile --force vim
dotfile --force vimrc
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
fi
