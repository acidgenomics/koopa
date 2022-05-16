#!/usr/bin/env bash

koopa_locate_cat() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='cat' \
        --opt-name='coreutils'
}
