#!/usr/bin/env bash

koopa_fedora_uninstall_azure_cli_binary() {
    koopa_uninstall_app \
        --name-fancy='Azure CLI (binary)' \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}
