#!/usr/bin/env bash

main() {
    # """
    # Install ripgrep-all.
    # @note Updated 2023-08-29.
    # """
    local -A dict
    dict['git']='https://github.com/phiresky/ripgrep-all.git'
    dict['name']='ripgrep_all'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --name="${dict['name']}" \
        --tag="${dict['tag']}"
    return 0
}
