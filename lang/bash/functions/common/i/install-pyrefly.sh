#!/usr/bin/env bash

koopa_install_pyrefly() {
    koopa_install_app \
        --installer='python-package' \
        --name='pyrefly' \
        "$@"
}
