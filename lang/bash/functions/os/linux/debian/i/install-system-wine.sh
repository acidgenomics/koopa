#!/usr/bin/env bash

koopa_debian_install_system_wine() {
    koopa_install_app \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
