#!/usr/bin/env bash

# FIXME Need to add support for this.

koopa_macos_uninstall_system_gfortran() {
    koopa_uninstall_app \
        --name='gfortran' \
        --platform='macos' \
        --system \
        "$@"
}
