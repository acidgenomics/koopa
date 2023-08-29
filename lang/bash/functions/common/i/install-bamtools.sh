#!/usr/bin/env bash

koopa_install_bamtools() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bamtools' \
        "$@"
}
