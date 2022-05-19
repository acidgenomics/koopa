#!/usr/bin/env bash

koopa_debian_uninstall_azure_cli() {
    koopa_uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}
