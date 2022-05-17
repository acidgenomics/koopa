#!/usr/bin/env bash

koopa_update_dotfiles() {
    koopa_update_app \
        --name='dotfiles' \
        --name-fancy='Dotfiles' \
        "$@"
}
