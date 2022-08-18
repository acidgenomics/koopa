#!/usr/bin/env bash

koopa_install_ghostscript() {
    koopa_install_app \
        --link-in-bin='gs' \
        --name='ghostscript' \
        "$@"
}
