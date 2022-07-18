#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_wine() {
    koopa_install_app \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
