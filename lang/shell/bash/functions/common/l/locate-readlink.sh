#!/usr/bin/env bash

koopa_locate_readlink() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='readlink' \
        --opt-name='coreutils'
}
