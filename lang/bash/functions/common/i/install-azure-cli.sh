#!/usr/bin/env bash

koopa_install_azure_cli() {
    koopa_install_app \
        --installer='python-package' \
        --name='azure-cli' \
        "$@"
}
