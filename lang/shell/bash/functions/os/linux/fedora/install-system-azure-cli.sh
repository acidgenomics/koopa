#!/usr/bin/env bash

koopa_fedora_install_system_azure_cli() {
    koopa_install_app \
        --name-fancy='Azure CLI (binary)' \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}
