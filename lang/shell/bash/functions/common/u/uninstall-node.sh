#!/usr/bin/env bash

koopa_uninstall_node() {
    koopa_uninstall_app \
        --name='node' \
        --unlink-in-bin='node' \
        --unlink-in-bin='npm' \
        "$@"
}
