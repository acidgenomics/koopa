#!/usr/bin/env bash

koopa_install_node() {
    koopa_install_app \
        --link-in-bin='node' \
        --link-in-bin='npm' \
        --name='node' \
        "$@"
}
