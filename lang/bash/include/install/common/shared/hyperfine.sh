#!/usr/bin/env bash

main() {
    # """
    # Install hyperfine.
    # @note Updated 2023-10-10.
    # """
    local -A dict
    dict['git']='https://github.com/sharkdp/hyperfine.git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['tag']}"
    return 0
}
