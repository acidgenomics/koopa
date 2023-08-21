#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='py-spy' \
        -D --package-name='py_spy'
}
