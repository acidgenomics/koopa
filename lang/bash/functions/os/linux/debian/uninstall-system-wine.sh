#!/usr/bin/env bash

_koopa_debian_uninstall_system_wine() {
    _koopa_uninstall_app \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
