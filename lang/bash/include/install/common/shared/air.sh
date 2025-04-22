#!/usr/bin/env bash

main() {
    # """
    # Install air.
    # @note Updated 2025-04-22.
    #
    # Binary installer:
    # https://github.com/posit-dev/air/releases/latest/download/air-installer.sh
    # """
    local -A dict
    dict['git']='https://github.com/posit-dev/air'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['version']}"
    return 0
}
