#!/usr/bin/env bash

koopa_install_sox() {
    koopa_install_app \
        --installer='conda-package' \
        --name='sox' \
        "$@"
}
