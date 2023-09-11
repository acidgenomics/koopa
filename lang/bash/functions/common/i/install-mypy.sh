#!/usr/bin/env bash

koopa_install_mypy() {
    koopa_install_app \
        --installer='python-package' \
        --name='mypy' \
        "$@"
}
