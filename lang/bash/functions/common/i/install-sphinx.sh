#!/usr/bin/env bash

koopa_install_sphinx() {
    koopa_install_app \
        --installer='python-package' \
        --name='sphinx' \
        "$@"
}
