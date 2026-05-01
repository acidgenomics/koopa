#!/usr/bin/env bash

main() {
    # """
    # Install gdbm.
    # @note Updated 2023-08-30.
    # """
    _koopa_activate_app 'readline'
    _koopa_install_gnu_app -D '--disable-static'
    return 0
}
