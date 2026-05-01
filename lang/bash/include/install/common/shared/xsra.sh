#!/usr/bin/env bash

main() {
    _koopa_activate_app --build-only 'cmake'
    _koopa_install_rust_package
    return 0
}
