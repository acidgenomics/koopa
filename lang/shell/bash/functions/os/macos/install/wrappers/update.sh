#!/usr/bin/env bash

koopa::macos_update_google_cloud_sdk() { # {{{1
    koopa::update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='macos' \
        --system \
        "$@"
}
