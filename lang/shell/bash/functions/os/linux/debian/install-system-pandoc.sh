#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_pandoc() {
    koopa_install_app \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}
