#!/usr/bin/env bash

main() {
    # """
    # Install mcfly.
    # @note Updated 2024-05-21.
    # """
    local -A dict
    dict['git']='https://github.com/cantino/mcfly.git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['tag']}"
    return 0
}
