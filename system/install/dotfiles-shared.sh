#!/usr/bin/env bash
set -Eeu -o pipefail

## Install general user dot files.
## Updated 2019-06-21.

dotfile --force condarc
dotfile --force gitignore
dotfile --force screenrc
dotfile --force spacemacs
dotfile --force tmux.conf
dotfile --force vim
dotfile --force vimrc

