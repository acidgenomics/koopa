#!/usr/bin/env bash

# FIXME Is this problematic with system R?
# FIXME Need to rethink this.

koopa_install_r_packages() {
    koopa_install_app \
        --name='r-packages' \
        "$@"
}
