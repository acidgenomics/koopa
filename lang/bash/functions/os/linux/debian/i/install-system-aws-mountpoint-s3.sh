#!/usr/bin/env bash

koopa_debian_install_system_aws_mountpoint_s3() {
    koopa_install_app \
        --name='aws-mountpoint-s3' \
        --platform='debian' \
        --system \
        "$@"
}
