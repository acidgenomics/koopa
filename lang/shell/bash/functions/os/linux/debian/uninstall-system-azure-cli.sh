#!/usr/bin/env bash

# FIXME Ensure we unlink in koopa bin.

koopa_debian_uninstall_system_azure_cli() {
    koopa_uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}
