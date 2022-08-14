#!/usr/bin/env bash

koopa_install_azure_cli() {
    koopa_install_app \
        --link-in-bin='az' \
        --name='azure-cli' \
        "$@"
}
