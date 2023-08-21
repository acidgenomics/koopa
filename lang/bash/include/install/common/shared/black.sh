#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='black' \
        -D --pip-name='black[d]'
}
