#!/usr/bin/env bash

koopa_install_node() {
    koopa_install_app \
        --link-in-bin='bin/node' \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}
