#!/usr/bin/env bash

koopa_install_mcfly() {
    koopa_install_app \
        --link-in-bin='bin/mcfly' \
        --name='mcfly' \
        --installer='rust-package' \
        "$@"
}
