#!/usr/bin/env bash

koopa_install_latch() {
    koopa_install_app \
        --installer='python-package' \
        --name='latch' \
        -D --python-version='3.11' \
        "$@"
}
