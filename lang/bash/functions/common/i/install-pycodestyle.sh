#!/usr/bin/env bash

koopa_install_pycodestyle() {
    koopa_install_app \
        --installer='python-package' \
        --name='pycodestyle' \
        "$@"
}
