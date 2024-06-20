#!/usr/bin/env bash

koopa_uninstall_aws_azure_login() {
    koopa_uninstall_app \
        --name='aws-azure-login' \
        "$@"
}
