#!/usr/bin/env bash

koopa_fedora_install_google_cloud_sdk() {
    koopa_install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
}
