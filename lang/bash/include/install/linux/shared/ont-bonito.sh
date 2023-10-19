#!/usr/bin/env bash

main() {
    koopa_activate_app 'zlib'
    koopa_install_python_package \
        --python-version='3.11'
    return 0
}
