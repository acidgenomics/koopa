#!/usr/bin/env bash

koopa_locate_openssl() {
    koopa_locate_app \
        --app-name='openssl3' \
        --bin-name='openssl' \
        "$@"
}
