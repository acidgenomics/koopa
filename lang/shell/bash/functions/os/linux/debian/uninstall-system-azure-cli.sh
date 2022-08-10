#!/usr/bin/env bash

koopa_debian_uninstall_system_azure_cli() {
    koopa_uninstall_app \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}
