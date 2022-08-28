#!/usr/bin/env bash

koopa_uninstall_pkg_config() {
    koopa_uninstall_app \
        --name='pkg-config' \
        "$@"
}
