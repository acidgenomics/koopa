#!/usr/bin/env bash

koopa_fedora_install_azure_cli() {
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}
