#!/usr/bin/env bash

# FIXME Simplify this script to simply delete packages inside site library.

koopa_uninstall_r_packages() {
    koopa_uninstall_app \
        --name='r-packages' \
        "$@"
}
