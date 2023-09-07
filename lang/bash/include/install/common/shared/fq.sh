#!/usr/bin/env bash

main() {
    # """
    # Install fq.
    # @note Updated 2023-09-07.
    # """
    local -A dict
    dict['git']='https://github.com/stjude-rust-labs/fq.git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['tag']}"
    return 0
}
