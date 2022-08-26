#!/usr/bin/env bash

koopa_locate_uname() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guname' \
        "$@" \
}
