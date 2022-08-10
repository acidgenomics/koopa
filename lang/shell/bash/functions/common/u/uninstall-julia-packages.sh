#!/usr/bin/env bash

koopa_uninstall_julia_packages() {
    koopa_uninstall_app \
        --name='julia-packages' \
        --prefix="$(koopa_julia_packages_prefix)" \
        "$@"
}
