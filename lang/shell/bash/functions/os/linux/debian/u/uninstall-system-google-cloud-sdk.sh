#!/usr/bin/env bash

koopa_debian_uninstall_system_google_cloud_sdk() {
    koopa_uninstall_app \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}
