#!/usr/bin/env bash

koopa_linux_install_aws_cli() {
    koopa_install_app \
        --name='aws-cli' \
        --platform='linux' \
        "$@"
}
