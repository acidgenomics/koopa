#!/usr/bin/env bash

koopa_install_aws_azure_login() {
    koopa_install_app \
        --installer='node-package' \
        --name='aws-azure-login' \
        "$@"
}
