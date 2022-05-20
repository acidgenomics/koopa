#!/usr/bin/env bash

koopa_install_dotfiles() {
    koopa_install_app \
        --name-fancy='Dotfiles' \
        --name='dotfiles' \
        "$@"
}
