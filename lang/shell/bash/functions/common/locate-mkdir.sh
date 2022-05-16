#!/usr/bin/env bash

koopa_locate_mkdir() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='mkdir' \
        --opt-name='coreutils'
}
