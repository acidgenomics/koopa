#!/usr/bin/env bash

koopa_locate_tee() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='tee' \
        --opt-name='coreutils'
}
