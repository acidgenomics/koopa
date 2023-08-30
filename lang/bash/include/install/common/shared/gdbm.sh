#!/usr/bin/env bash

main() {
    # """
    # Install gdbm.
    # @note Updated 2023-08-30.
    # """
    koopa_activate_app 'readline'
    koopa_install_gnu_app -D '--disable-static'
    return 0
}
