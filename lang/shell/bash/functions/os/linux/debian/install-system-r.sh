#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_r() {
    koopa_install_app \
        --name='r' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}
