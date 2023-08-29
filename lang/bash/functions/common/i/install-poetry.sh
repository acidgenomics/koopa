#!/usr/bin/env bash

koopa_install_poetry() {
    koopa_install_app \
        --installer='python-package' \
        --name='poetry' \
        "$@"
}
