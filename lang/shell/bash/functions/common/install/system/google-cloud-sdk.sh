#!/usr/bin/env bash

koopa::update_google_cloud_sdk() { # {{{1
    koopa:::update_app \
        --name-fancy='Google Cloud SDK' \
        --name='gcloud'
}
