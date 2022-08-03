#!/usr/bin/env bash

# FIXME This is currently broken...rethink...
# FIXME Simplify this script to simply delete packages inside site library.

koopa_uninstall_r_packages() {
    koopa_uninstall_app \
        --name='r-packages' \
        "$@"
}
