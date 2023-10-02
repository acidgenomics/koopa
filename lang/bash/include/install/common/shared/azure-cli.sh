#!/usr/bin/env bash

main() {
    koopa_install_python_package \
        --package-name='azure_cli' \
        --python-version='3.11'
    return 0
}
