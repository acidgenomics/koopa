#!/usr/bin/env bash

main() {
    koopa_install_python_package \
        --pip-name='black[d]' \
        --python-version='3.11'
    return 0
}
