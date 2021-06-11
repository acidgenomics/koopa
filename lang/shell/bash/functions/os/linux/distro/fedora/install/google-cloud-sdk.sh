#!/usr/bin/env bash

koopa::fedora_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2020-08-06.
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-yum
    # """
    local name_fancy
    name_fancy='Google Cloud SDK'
    if koopa::is_installed 'gcloud'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    koopa::install_start "$name_fancy"
    koopa::fedora_add_google_cloud_sdk_repo
    sudo dnf -y install google-cloud-sdk
    koopa::install_success "$name_fancy"
    return 0
}

koopa::fedora_uninstall_google_cloud_sdk() { # {{{1
    # """
    # Uninstall Google Cloud SDK.
    # @note Updated 2021-06-11.
    # """
    koopa::stop 'FIXME'
}
