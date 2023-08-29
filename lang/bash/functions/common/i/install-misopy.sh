#!/usr/bin/env bash

koopa_install_misopy() {
    koopa_install_app \
        --installer='conda-package' \
        --name='misopy' \
        "$@"
}
