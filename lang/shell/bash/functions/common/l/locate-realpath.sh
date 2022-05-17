#!/usr/bin/env bash

koopa_locate_realpath() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='realpath' \
        --opt-name='coreutils'
}
