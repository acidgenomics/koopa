#!/usr/bin/env bash

koopa_install_azure_cli() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/az' \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        "$@"
}
