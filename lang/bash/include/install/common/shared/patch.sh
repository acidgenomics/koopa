#!/usr/bin/env bash

main() {
    # """
    # Install patch.
    # @note Updated 2023-08-30.
    # """
    if koopa_is_linux
    then
        koopa_activate_app 'attr'
    fi
    koopa_install_gnu_app
    return 0
}
