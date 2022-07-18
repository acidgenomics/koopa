#!/usr/bin/env bash

koopa_install_node_binary() {
    koopa_install_app \
        --installer='node-binary' \
        --link-in-bin='node' \
        --link-in-bin='npm' \
        --name='node' \
        "$@"
}
