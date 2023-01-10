#!/usr/bin/env bash

koopa_debian_install_system_pandoc() {
    koopa_install_app \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}
