#!/usr/bin/env bash

koopa_locate_gpg_agent() {
    koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg-agent' \
        "$@" \
}
