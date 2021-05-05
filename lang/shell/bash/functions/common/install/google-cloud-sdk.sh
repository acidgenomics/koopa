#!/usr/bin/env bash

koopa::update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2021-05-05.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    koopa::is_installed gcloud || return 0
    name_fancy='Google Cloud SDK'
    koopa::update_start "$name_fancy"
    if koopa::is_installed brew && koopa::is_macos
    then
        koopa::alert_note 'Homebrew is installed. Skipping manual update.'
        return 0
    fi
    gcloud components update
    koopa::update_success "$name_fancy"
    return 0
}
