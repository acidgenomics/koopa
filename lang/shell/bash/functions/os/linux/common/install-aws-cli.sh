#!/usr/bin/env bash

koopa_linux_install_aws_cli() {
    koopa_install_app \
        --link-in-bin='aws' \
        --name='aws-cli' \
        --platform='linux' \
        "$@"
}
