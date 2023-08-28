#!/usr/bin/env bash

main() {
    # """
    # Install tuc.
    # @note Updated 2023-08-28.
    # """
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='tuc' \
        -D '--features=regex'
}
