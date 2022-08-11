#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_automake() {
    koopa_install_app \
        --activate-opt='autoconf' \
        --installer='gnu-app' \
        --name='automake' \
        "$@"
}
