#!/usr/bin/env bash

koopa_locate_pkg_config() {
    koopa_locate_app \
        --app-name='pkg-config' \
        --bin-name='pkg-config' \
        "$@"
}
