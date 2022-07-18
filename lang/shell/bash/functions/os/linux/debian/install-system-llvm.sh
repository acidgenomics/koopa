#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_llvm() {
    koopa_install_app \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}
