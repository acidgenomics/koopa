#!/usr/bin/env bash

_koopa_debian_install_system_wine() {
    _koopa_install_app \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
