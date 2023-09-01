#!/usr/bin/env bash

main() {
    # """
    # Install ripgrep.
    # @note Updated 2023-08-29.
    # """
    koopa_activate_app 'pcre2'
    koopa_install_rust_package --features='pcre2'
    return 0
}
