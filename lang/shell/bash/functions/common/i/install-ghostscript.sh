#!/usr/bin/env bash

koopa_install_ghostscript() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/gs' \
        --name='ghostscript' \
        "$@"
}
