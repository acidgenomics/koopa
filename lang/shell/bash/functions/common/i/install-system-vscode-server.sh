#!/usr/bin/env bash

koopa_install_system_vscode_server() {
    koopa_install_app \
        --name='vscode-server' \
        --system \
        "$@"
}
