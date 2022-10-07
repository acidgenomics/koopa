#!/usr/bin/env bash

koopa_uninstall_system_vscode_server() {
    koopa_uninstall_app \
        --name='vscode-server' \
        --system \
        "$@"
}
