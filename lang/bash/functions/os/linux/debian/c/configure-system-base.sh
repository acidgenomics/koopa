#!/usr/bin/env bash

koopa_debian_configure_system_base() {
    koopa_configure_app \
        --name='base' \
        --platform='debian' \
        --system \
        "$@"
}
