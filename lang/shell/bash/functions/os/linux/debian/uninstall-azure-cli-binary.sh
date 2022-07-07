#!/usr/bin/env bash

koopa_debian_uninstall_azure_cli_binary() {
    koopa_uninstall_app \
        --name-fancy='Azure CLI (binary)' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}
