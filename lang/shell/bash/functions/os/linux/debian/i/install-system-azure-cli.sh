#!/usr/bin/env bash

koopa_debian_install_system_azure_cli() {
    koopa_install_app \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}