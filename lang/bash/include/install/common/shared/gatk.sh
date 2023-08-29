#!/usr/bin/env bash

main() {
    # """
    # Install GATK.
    # @note Updated 2023-08-29.
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_conda_package \
        --name='gatk4' \
        --prefix="${dict['prefix']}" \
        --version="${dict['version']}"
    return 0
}
