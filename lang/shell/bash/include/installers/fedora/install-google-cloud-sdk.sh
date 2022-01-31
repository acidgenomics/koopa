#!/usr/bin/env bash

koopa:::fedora_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-yum
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::fedora_add_google_cloud_sdk_repo
    koopa::fedora_dnf_install 'google-cloud-sdk'
    return 0
}
