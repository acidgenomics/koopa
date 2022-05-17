#!/usr/bin/env bash

koopa_locate_wc() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='wc' \
        --opt-name='coreutils'
}
