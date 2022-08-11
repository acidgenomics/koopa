#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_units() {
    koopa_install_app \
        --activate-opt='readline' \
        --installer='gnu-app' \
        --link-in-bin='units' \
        --name='units' \
        "$@"
}
