#!/usr/bin/env bash

koopa_install_mcfly() {
    koopa_install_app \
        --link-in-bin='mcfly' \
        --name='mcfly' \
        "$@"
}
