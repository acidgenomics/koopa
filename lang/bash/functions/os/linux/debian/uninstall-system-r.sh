#!/usr/bin/env bash

_koopa_debian_uninstall_system_r() {
    _koopa_uninstall_app \
        --name='r' \
        --platform='debian' \
        --system \
        "$@"
}
