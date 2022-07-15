#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_azure_cli() {
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}
