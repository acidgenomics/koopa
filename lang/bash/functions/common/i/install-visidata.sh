#!/usr/bin/env bash

koopa_install_visidata() {
    koopa_install_app \
        --installer='python-package' \
        --name='visidata' \
        "$@"
}
