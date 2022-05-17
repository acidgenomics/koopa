#!/usr/bin/env bash

koopa_uninstall_aws_cli() {
    koopa_uninstall_app \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --unlink-in-bin='aws' \
        "$@"
}
