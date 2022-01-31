#!/usr/bin/env bash

koopa:::debian_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2022-01-27.
    #
    # Required packages:
    # - apt-transport-https
    # - ca-certificates
    # - curl
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-apt-get
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::debian_apt_add_google_cloud_sdk_repo
    koopa::debian_apt_install 'google-cloud-sdk'
    return 0
}
