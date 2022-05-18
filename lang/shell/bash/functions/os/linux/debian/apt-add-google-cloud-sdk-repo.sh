#!/usr/bin/env bash

koopa_debian_apt_add_google_cloud_sdk_repo() {
    # """
    # Add Google Cloud SDK apt repo.
    # @note Updated 2021-11-09.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_google_cloud_key
    koopa_debian_apt_add_repo \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --key-name='google-cloud' \
        --url='https://packages.cloud.google.com/apt' \
        --distribution='cloud-sdk' \
        --component='main'
    return 0
}
