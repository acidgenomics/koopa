#!/usr/bin/env bash

main() {
    # Install starship.
    # @note Updated 2023-08-28.
    # ""
    koopa_activate_app --build-only 'cmake'
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='starship'
}
