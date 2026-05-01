#!/usr/bin/env bash

_koopa_locate_pkg_config() {
    _koopa_locate_app \
        --app-name='pkg-config' \
        --bin-name='pkg-config' \
        "$@"
}
