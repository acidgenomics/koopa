#!/usr/bin/env bash

koopa_configure_user_dotfiles() {
    koopa_configure_app \
        --name='dotfiles' \
        --user \
        "$@"
}
