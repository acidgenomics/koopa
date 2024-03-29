#!/usr/bin/env bash

main() {
    # Install zenith.
    # @note Updated 2024-03-29.
    # ""
    local -A dict
    dict['git']='https://github.com/bvaisvil/zenith.git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['tag']}"
    return 0
}
