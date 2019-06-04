#!/usr/bin/env bash
set -Eeuxo pipefail

# dotfiles
(
    git submodule add \
        https://github.com/mjsteinbaugh/dotfiles.git \
        dotfiles
    cd dotfiles || exit 1
    ./INSTALL.sh
)
