#!/usr/bin/env bash

# FIXME Need to rework this approach for system R.
# FIXME Run into prefix check issues at the end...

koopa_install_r_packages() {
    koopa_install_app \
        --name='r-packages' \
        --no-prefix-check \
        "$@"
}
