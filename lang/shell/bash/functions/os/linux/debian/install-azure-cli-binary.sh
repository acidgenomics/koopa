#!/usr/bin/env bash

koopa_debian_install_azure_cli_binary() {
    koopa_install_app \
        --name-fancy='Azure CLI (binary)' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}
