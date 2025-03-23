#!/usr/bin/env bash

koopa_install_pyflakes() {
    koopa_install_app \
        --installer='python-package' \
        --name='pyflakes' \
        "$@"
}
