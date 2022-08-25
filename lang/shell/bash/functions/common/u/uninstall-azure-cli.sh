#!/usr/bin/env bash

koopa_uninstall_azure_cli() {
    koopa_uninstall_app \
        --name='azure-cli' \
        "$@"
}
