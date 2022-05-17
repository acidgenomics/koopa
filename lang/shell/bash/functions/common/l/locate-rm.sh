#!/usr/bin/env bash

koopa_locate_rm() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='rm' \
        --opt-name='coreutils'
}
