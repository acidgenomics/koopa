#!/usr/bin/env bash

koopa_install_vulture() {
    koopa_install_app \
        --installer='python-package' \
        --name='vulture' \
        "$@"
}
