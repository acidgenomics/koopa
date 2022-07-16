#!/usr/bin/env bash

koopa_install_azure_cli() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='az' \
        --name='azure-cli' \
        "$@"
}
