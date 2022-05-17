#!/usr/bin/env bash

koopa_locate_gpg_agent() {
    koopa_locate_app \
        --app-name='gpg-agent' \
        --opt-name='gnupg'
}
