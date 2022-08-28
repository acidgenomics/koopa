#!/usr/bin/env bash

koopa_uninstall_google_cloud_sdk() {
    koopa_uninstall_app \
        --name='google-cloud-sdk' \
        "$@"
}
