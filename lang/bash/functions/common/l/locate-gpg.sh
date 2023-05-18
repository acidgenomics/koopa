#!/usr/bin/env bash

koopa_locate_gpg() {
    koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg' \
        "$@"
}
