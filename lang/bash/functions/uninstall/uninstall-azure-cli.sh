#!/usr/bin/env bash

_koopa_uninstall_azure_cli() {
    _koopa_uninstall_app \
        --name='azure-cli' \
        "$@"
}
