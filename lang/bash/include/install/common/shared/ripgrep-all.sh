#!/usr/bin/env bash

main() {
    # """
    # Install ripgrep-all.
    # @note Updated 2023-08-29.
    # """
    local -A dict
    dict['name']='ripgrep_all'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['git']='https://github.com/phiresky/ripgrep-all.git'
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --tag="${dict['tag']}" \
        --version="${dict['version']}"
    return 0
}
