#!/usr/bin/env bash

_koopa_debian_configure_system_base() {
    _koopa_configure_app \
        --name='base' \
        --platform='debian' \
        --system \
        "$@"
}
