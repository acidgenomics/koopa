#!/usr/bin/env bash

koopa_install_node() {
    koopa_install_app \
        --link-in-bin='bin/node' \
        --link-in-bin='bin/npm' \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}
