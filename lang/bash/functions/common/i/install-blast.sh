#!/usr/bin/env bash

koopa_install_blast() {
    koopa_install_app \
        --installer='conda-package' \
        --name='blast' \
        "$@"
}
