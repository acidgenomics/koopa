#!/usr/bin/env bash

main() {
    koopa_activate_app 'gmp'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='mpfr'
}
