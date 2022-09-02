#!/usr/bin/env bash

# NOTE Consider nesting this under 'configure' instead of 'install'.

koopa_macos_install_system_defaults() {
    koopa_install_app \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}
