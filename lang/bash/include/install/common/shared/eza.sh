#!/usr/bin/env bash

main() {
    # Install eza.
    # @note Updated 2024-09-27.
    # ""
    local -A dict
    dict['git']='https://github.com/eza-community/eza.git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['tag']}"
    return 0
}
