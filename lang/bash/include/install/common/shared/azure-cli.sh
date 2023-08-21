#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='azure-cli' \
        -D --package-name='azure_cli'
}
