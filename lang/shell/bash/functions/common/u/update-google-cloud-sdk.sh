#!/usr/bin/env bash

koopa_update_google_cloud_sdk() {
    koopa_update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --system \
        "$@"
}
