#!/usr/bin/env bash

koopa_install_marimo() {
    koopa_install_app \
        --installer='python-package' \
        --name='marimo' \
        "$@"
}
