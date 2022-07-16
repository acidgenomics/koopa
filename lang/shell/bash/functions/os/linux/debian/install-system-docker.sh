#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_docker() {
    koopa_install_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
