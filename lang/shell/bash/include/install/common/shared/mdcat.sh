#!/usr/bin/env bash

# FIXME Need to resolve openssl issue:
# mdcat compile fail -- ubuntu 22
# openssl not found
# openssl.pc

main() {
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='mdcat' \
        "$@"
}
