#!/usr/bin/env bash

# FIXME Need to configure '/etc/shells' for shared install.

koopa_install_fish() {
    koopa_install_app \
        --name='fish' \
        "$@"
}
