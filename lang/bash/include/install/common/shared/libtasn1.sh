#!/usr/bin/env bash

main() {
    # """
    # Install libtasn1.
    # @note Updated 2023-08-30.
    # """
    koopa_install_gnu_app -D '--disable-static'
    return 0
}
