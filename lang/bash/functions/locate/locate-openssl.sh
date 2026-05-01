#!/usr/bin/env bash

_koopa_locate_openssl() {
    _koopa_locate_app \
        --app-name='openssl' \
        --bin-name='openssl' \
        "$@"
}
