#!/usr/bin/env bash

koopa_install_pyright() {
    koopa_install_app \
        --installer='python-package' \
        --name='pyright' \
        "$@"
}
