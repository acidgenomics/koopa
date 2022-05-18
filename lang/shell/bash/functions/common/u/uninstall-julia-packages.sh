#!/usr/bin/env bash

koopa_uninstall_julia_packages() {
    koopa_uninstall_app \
        --name-fancy='Julia packages' \
        --name='julia-packages' \
        "$@"
}
