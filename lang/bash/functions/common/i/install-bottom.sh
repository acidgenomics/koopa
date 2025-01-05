#!/usr/bin/env bash

koopa_install_bottom() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bottom' \
        "$@"
}
