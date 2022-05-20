#!/usr/bin/env bash

koopa_debian_install_nodesource_node_binary() {
    koopa_install_app \
        --name-fancy='NodeSource Node.js' \
        --name='nodesource-node-binary' \
        --platform='debian' \
        --system \
        "$@"
}
