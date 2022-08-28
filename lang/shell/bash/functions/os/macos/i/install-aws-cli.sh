#!/usr/bin/env bash

koopa_macos_install_aws_cli() {
    koopa_install_app \
        --name='aws-cli' \
        --platform='macos' \
        "$@"
}
