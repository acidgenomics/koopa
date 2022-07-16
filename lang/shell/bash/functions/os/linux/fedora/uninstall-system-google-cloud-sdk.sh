#!/usr/bin/env bash

koopa_fedora_uninstall_system_google_cloud_sdk() {
    koopa_uninstall_app \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
}
