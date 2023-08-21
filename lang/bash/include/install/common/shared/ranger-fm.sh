#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='ranger-fm' \
        -D --package-name='ranger_fm'
}
