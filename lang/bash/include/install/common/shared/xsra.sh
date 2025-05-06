#!/usr/bin/env bash

main() {
    koopa_activate_app --build-only 'cmake'
    koopa_install_rust_package
    return 0
}
