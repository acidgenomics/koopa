#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_groff() {
    koopa_install_app \
        --activate-opt='texinfo' \
        --installer='gnu-app' \
        --link-in-bin='groff' \
        --name='groff' \
        "$@"
}
