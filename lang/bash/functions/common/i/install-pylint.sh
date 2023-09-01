#!/usr/bin/env bash

koopa_install_pylint() {
    koopa_install_app \
        --installer='python-package' \
        --name='pylint' \
        "$@"
}
