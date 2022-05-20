#!/usr/bin/env bash

koopa_uninstall_node() {
    koopa_uninstall_app \
        --name-fancy='Node.js' \
        --name='node' \
        --unlink-in-bin='node' \
        "$@"
}
