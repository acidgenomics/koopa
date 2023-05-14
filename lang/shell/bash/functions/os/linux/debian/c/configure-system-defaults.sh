#!/usr/bin/env bash

koopa_debian_configure_system_defaults() {
    koopa_configure_app \
        --name='defaults' \
        --platform='debian' \
        --system \
        "$@"
}
