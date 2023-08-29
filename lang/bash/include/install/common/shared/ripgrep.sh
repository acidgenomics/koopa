#!/usr/bin/env bash

main() {
    # """
    # Install ripgrep.
    # @note Updated 2023-08-29.
    # """
    local -A dict
    koopa_activate_app 'pcre2'
    dict['features']='pcre2'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_rust_package \
        --features="${dict['features']}" \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --version="${dict['version']}"
    return 0
}
