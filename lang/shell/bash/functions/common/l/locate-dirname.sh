#!/usr/bin/env bash

koopa_locate_dirname() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='dirname' \
        --opt-name='coreutils'
}
