#!/usr/bin/env bash

# FIXME Rethink this approach, not using 'julia-packages'.

koopa_uninstall_julia_packages() {
    koopa_uninstall_app \
        --name='julia-packages' \
        "$@"
}
