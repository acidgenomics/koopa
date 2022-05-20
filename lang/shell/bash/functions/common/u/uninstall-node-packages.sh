#!/usr/bin/env bash

koopa_uninstall_node_packages() {
    koopa_uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        --unlink-in-bin='bash-language-server' \
        --unlink-in-bin='gtop' \
        --unlink-in-bin='npm' \
        --unlink-in-bin='prettier' \
        "$@"
}
