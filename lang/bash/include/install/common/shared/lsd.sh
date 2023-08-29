#!/usr/bin/env bash

main() {
    # """
    # Install lsd.
    # @note Updated 2023-08-29.
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['git']='https://github.com/lsd-rs/lsd.git'
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['tag']}"
    return 0
}
