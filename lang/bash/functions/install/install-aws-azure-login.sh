#!/usr/bin/env bash

_koopa_install_aws_azure_login() {
    _koopa_install_app \
        --installer='node-package' \
        --name='aws-azure-login' \
        "$@"
}
