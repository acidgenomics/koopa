#!/usr/bin/env bash

koopa_debian_uninstall_google_cloud_sdk_binary() {
    koopa_uninstall_app \
        --name-fancy='Google Cloud SDK (binary)' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}
