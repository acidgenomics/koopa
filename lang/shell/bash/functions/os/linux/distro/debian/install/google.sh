#!/usr/bin/env bash

# FIXME Need to add an uninstaller.

koopa::debian_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2021-06-04.
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
    name_fancy='Google Cloud SDK'
    if koopa::is_installed 'gcloud'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    koopa::install_start "$name_fancy"
    koopa::apt_add_google_cloud_sdk_repo
    koopa::apt_install google-cloud-sdk
    koopa::install_success "$name_fancy"
    return 0
}

