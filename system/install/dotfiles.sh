#!/usr/bin/env bash
set -Eeuo pipefail

echo "Symlinking dot files."

os="${KOOPA_OS_NAME:-}"
host="${KOOPA_HOST_NAME:-}"

(
    cd ~
    
    # Remove legacy symlinks.
    rm -rf .dotfiles
    
    case "$host" in
        azure) dotfile shrc-azure shrc ;;
            *) dotfile shrc ;;
    esac
    
    rm -f .bashrc .bash_profile .kshrc .zshrc
    ln -s .shrc .bashrc
    ln -s .shrc .kshrc
    ln -s .shrc .zshrc
    ln -s .bashrc .bash_profile

    dotfile condarc
    dotfile gitconfig
    dotfile gitignore_global
    dotfile Rprofile
    dotfile spacemacs
    dotfile tmux.conf
    dotfile vim
    dotfile vimrc

    if [[ "$os" == "darwin" ]]
    then
        dotfile Renviron-darwin Renviron
    elif [[ "$host" == "harvard-o2" ]]
    then
        dotfile Renviron-harvard-o2 Renviron 
    elif [[ "$host" == "harvard-odyssey" ]]
    then
        dotfile Renviron-harvard-odyssey Renviron
    fi
)

unset -v host os
