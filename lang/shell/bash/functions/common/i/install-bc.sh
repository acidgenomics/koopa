#!/usr/bin/env bash

# FIXME Need to rework this as an internal install command, so we don't hit
# activation issues when installing as a binary package.

koopa_install_bc() {
    koopa_install_app \
        --activate-build-opt='texinfo' \
        --installer='gnu-app' \
        --link-in-bin='bc' \
        --name='bc' \
        "$@"
}
