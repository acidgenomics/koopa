#!/usr/bin/env bash

# FIXME Break out to separate installer.

koopa_install_automake() {
    koopa_install_app \
        --activate-opt='autoconf' \
        --installer='gnu-app' \
        --name='automake' \
        "$@"
}
