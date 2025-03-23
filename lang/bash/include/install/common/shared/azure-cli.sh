#!/usr/bin/env bash

main() {
    koopa_install_python_package \
        --egg-name='azure_cli' \
        --python-version='3.12'
    return 0
}
