#!/usr/bin/env bash

koopa_install_node_binary() {
    koopa_install_app \
        --installer='node-binary' \
        --link-in-bin='bin/node' \
        --link-in-bin='bin/npm' \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}
