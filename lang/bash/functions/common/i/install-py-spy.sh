#!/usr/bin/env bash

koopa_install_py_spy() {
    koopa_install_app \
        --installer='python-package' \
        --name='py-spy' \
        "$@"
}
