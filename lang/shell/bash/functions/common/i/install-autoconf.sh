#!/usr/bin/env bash

# FIXME Break out to individual install recipe, rather than using 'gnu-app'.

koopa_install_autoconf() {
    koopa_install_app \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --name='autoconf' \
        "$@"
}
