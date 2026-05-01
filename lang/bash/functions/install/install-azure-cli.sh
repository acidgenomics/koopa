#!/usr/bin/env bash

_koopa_install_azure_cli() {
    _koopa_install_app \
        --installer='python-package' \
        --name='azure-cli' \
        -D --python-version='3.13' \
        "$@"
}
