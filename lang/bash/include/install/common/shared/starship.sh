#!/usr/bin/env bash

main() {
    # Install starship.
    # @note Updated 2023-08-29.
    # ""
    koopa_activate_app --build-only 'cmake'
    koopa_install_rust_package
    return 0
}
