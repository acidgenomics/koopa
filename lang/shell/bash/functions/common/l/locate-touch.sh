#!/usr/bin/env bash

koopa_locate_touch() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='touch' \
        --opt-name='coreutils'
}
