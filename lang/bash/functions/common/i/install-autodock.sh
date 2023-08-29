#!/usr/bin/env bash

koopa_install_autodock() {
    koopa_install_app \
        --installer='conda-package' \
        --name='autodock' \
        "$@"
}
