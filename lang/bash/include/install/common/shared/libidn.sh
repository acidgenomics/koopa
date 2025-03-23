#!/usr/bin/env bash

main() {
    koopa_install_gnu_app \
        --package-name='libidn2' \
        -D '--disable-static'
    return 0
}
