#!/usr/bin/env bash

koopa_debian_install_system_google_cloud_sdk() {
    koopa_install_app \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}
