#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_google_cloud_sdk() {
    koopa_install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}
