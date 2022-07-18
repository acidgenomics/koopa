#!/usr/bin/env bash

koopa_debian_apt_add_google_cloud_sdk_repo() {
    # """
    # Add Google Cloud SDK apt repo.
    # @note Updated 2022-07-15.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_google_cloud_key
    koopa_debian_apt_add_repo \
        --component='main' \
        --distribution='cloud-sdk' \
        --key-name='google-cloud' \
        --name='google-cloud-sdk' \
        --url='https://packages.cloud.google.com/apt'
    return 0
}
