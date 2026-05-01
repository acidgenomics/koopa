#!/usr/bin/env bash

_koopa_install_openssl3() {
    _koopa_install_app \
        --installer='openssl' \
        --name='openssl3' \
        "$@"
}
