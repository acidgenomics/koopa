#!/usr/bin/env bash

koopa_uninstall_node_binary() {
    koopa_uninstall_app \
        --name='node' \
        --unlink-in-bin='node' \
        --unlink-in-bin='npm' \
        "$@"
}
