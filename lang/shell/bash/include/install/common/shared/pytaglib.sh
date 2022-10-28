#!/usr/bin/env bash

main() {
    koopa_activate_app 'taglib'
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='pytaglib' \
        -D --python-version='3.10' \
        "$@"
}
