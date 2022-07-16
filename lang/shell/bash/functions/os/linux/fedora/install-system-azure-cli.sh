#!/usr/bin/env bash

koopa_fedora_install_system_azure_cli() {
    koopa_install_app \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}
