#!/usr/bin/env bash

koopa_debian_install_system_r() {
    koopa_install_app \
        --installer='r-binary' \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}
