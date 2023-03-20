#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='latch' \
        -D --python-version='3.10' \
        "$@"
}
