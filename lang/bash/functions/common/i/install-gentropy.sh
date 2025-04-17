#!/usr/bin/env bash

koopa_install_gentropy() {
    koopa_install_app \
        --installer='python-package' \
        --name='gentropy' \
        -D --python-version='3.10' \
        "$@"
}
