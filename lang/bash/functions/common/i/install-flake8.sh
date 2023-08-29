#!/usr/bin/env bash

koopa_install_flake8() {
    koopa_install_app \
        --installer='python-package' \
        --name='flake8' \
        "$@"
}
