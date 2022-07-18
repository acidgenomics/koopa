#!/usr/bin/env bash

koopa_install_google_cloud_sdk() {
    koopa_install_app \
        --link-in-bin='gcloud' \
        --name='google-cloud-sdk' \
        "$@"
}
