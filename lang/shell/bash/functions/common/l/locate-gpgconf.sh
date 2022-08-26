#!/usr/bin/env bash

koopa_locate_gpgconf() {
    koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpgconf' \
        "$@" \
}
