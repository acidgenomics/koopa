#!/usr/bin/env bash

koopa_debian_install_azure_cli() {
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}
