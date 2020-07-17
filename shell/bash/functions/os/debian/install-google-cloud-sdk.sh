#!/usr/bin/env bash

koopa::debian_install_google_cloud_sdk() {
    # """
    # https://cloud.google.com/sdk/docs/downloads-apt-get
    #
    # Required packages:
    # - apt-transport-https
    # - ca-certificates
    # - curl
    # """
    koopa::assert_has_no_args "$#"
    koopa::exit_if_installed gcloud
    name_fancy='Google Cloud SDK'
    koopa::install_start "$name_fancy"
    koopa::apt_add_google_cloud_sdk_repo
    koopa::apt_install google-cloud-sdk
    koopa::install_success "$name_fancy"
    return 0
}

