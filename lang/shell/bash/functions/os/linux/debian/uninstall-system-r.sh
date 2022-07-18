#!/usr/bin/env bash

koopa_debian_uninstall_system_r() {
    koopa_uninstall_app \
        --name='r' \
        --platform='debian' \
        --system \
        "$@"
}
