#!/usr/bin/env bash

koopa::debian_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2020-07-30.
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
    koopa::is_installed gcloud && return 0
    name_fancy='Google Cloud SDK'
    koopa::install_start "$name_fancy"
    koopa::apt_add_google_cloud_sdk_repo
    koopa::apt_install google-cloud-sdk
    koopa::install_success "$name_fancy"
    return 0
}

