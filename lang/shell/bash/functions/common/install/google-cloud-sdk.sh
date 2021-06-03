#!/usr/bin/env bash

koopa::update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2021-06-03.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Google Cloud SDK'
    if ! koopa::is_installed gcloud
    then
        koopa::alert_is_not_installed "$name_fancy"
        return 0
    fi
    koopa::update_start "$name_fancy"
    if koopa::is_installed brew && koopa::is_macos
    then
        koopa::alert_is_installed 'Homebrew'
        return 0
    fi
    gcloud components update
    koopa::update_success "$name_fancy"
    return 0
}
