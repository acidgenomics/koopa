#!/usr/bin/env bash

koopa_install_mcfly() {
    koopa_install_app \
        --installer='conda-package' \
        --name='mcfly' \
        "$@"
}
