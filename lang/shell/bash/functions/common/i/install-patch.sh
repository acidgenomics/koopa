#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_patch() {
    local install_args
    install_args=()
    if koopa_is_linux
    then
        install_args+=('--activate-opt=attr')
    fi
    install_args+=(
        '--installer=gnu-app'
        '--link-in-bin=patch'
        '--name=patch'
    )
    koopa_install_app "${install_args[@]}" "$@"
}
