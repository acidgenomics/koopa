#!/usr/bin/env bash

koopa_uninstall_google_cloud_sdk() {
    koopa_uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --unlink-in-bin='gcloud' \
        "$@"
}
