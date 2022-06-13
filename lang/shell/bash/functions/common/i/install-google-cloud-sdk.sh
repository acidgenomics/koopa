#!/usr/bin/env bash

koopa_install_google_cloud_sdk() {
    koopa_install_app \
        --link-in-bin='bin/gcloud' \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        "$@"
}
