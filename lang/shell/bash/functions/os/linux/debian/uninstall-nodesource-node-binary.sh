#!/usr/bin/env bash

koopa_debian_uninstall_nodesource_node_binary() {
    koopa_uninstall_app \
        --name-fancy='NodeSource Node.js' \
        --name='nodesource-node-binary' \
        --platform='debian' \
        --system \
        "$@"
}
