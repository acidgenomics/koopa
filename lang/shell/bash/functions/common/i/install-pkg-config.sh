#!/usr/bin/env bash

koopa_install_pkg_config() {
    koopa_install_app \
        --link-in-bin='pkg-config' \
        --name='pkg-config' \
        "$@"
}
