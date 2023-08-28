#!/usr/bin/env bash

main() {
    # """
    # Install ripgrep.
    # @note Updated 2023-08-28.
    # """
    koopa_activate_app 'pcre2'
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='ripgrep' \
        -D '--features=pcre2'
}
