#!/usr/bin/env bash

koopa_install_zellij() {
    koopa_install_app \
        --installer='conda-package' \
        --name='zellij' \
        "$@"
}
