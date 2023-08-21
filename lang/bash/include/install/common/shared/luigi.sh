#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='luigi' \
        -D --pip-name='luigi[toml]'
}
