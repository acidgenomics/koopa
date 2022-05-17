#!/usr/bin/env bash

koopa_locate_mktemp() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='mktemp' \
        --opt-name='coreutils'
}
