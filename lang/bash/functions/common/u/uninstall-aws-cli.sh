#!/usr/bin/env bash

koopa_uninstall_aws_cli() {
    koopa_uninstall_app \
        --name='aws-cli' \
        "$@"
}
