#!/usr/bin/env bash

koopa_locate_gpg() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='gpg' \
        --opt-name='gnupg'
}
