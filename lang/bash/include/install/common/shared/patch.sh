#!/usr/bin/env bash

main() {
    # """
    # Install patch.
    # @note Updated 2023-08-30.
    # """
    if _koopa_is_linux
    then
        _koopa_activate_app 'attr'
    fi
    _koopa_install_gnu_app
    return 0
}
