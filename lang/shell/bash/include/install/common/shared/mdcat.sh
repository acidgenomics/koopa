#!/usr/bin/env bash

main() {
    koopa_activate_app 'openssl3'
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='mdcat'
}
