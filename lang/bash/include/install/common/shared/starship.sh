#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
    return 0
}

install_from_rust() {
    # Install starship.
    # @note Updated 2024-03-22.
    # ""
    local -A dict
    koopa_activate_app --build-only 'cmake'
    dict['git']='https://github.com/starship/starship.git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['tag']="v${dict['version']}"
    koopa_install_rust_package \
        --git="${dict['git']}" \
        --tag="${dict['tag']}"
    return 0
}

main() {
    install_from_conda
    return 0
}
