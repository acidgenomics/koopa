#!/usr/bin/env bash

koopa::linux_update_google_cloud_sdk() { # {{{1
    koopa:::update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='linux' \
        "$@"
}

koopa:::linux_update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2021-09-20.
    # """
    local gcloud
    koopa::assert_has_no_args "$#"
    gcloud="$(koopa::locate_gcloud)"
    "$gcloud" components update
    return 0
}
