#!/usr/bin/env bash

koopa_locate_stat() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='stat' \
        --opt-name='coreutils'
}
