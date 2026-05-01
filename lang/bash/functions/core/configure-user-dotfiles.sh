#!/usr/bin/env bash

_koopa_configure_user_dotfiles() {
    _koopa_configure_app \
        --name='dotfiles' \
        --user \
        "$@"
}
