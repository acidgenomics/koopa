#!/usr/bin/env bash

koopa_locate_tail() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='tail' \
        --opt-name='coreutils'
}
