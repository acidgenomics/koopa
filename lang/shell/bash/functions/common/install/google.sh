#!/usr/bin/env bash

koopa::update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2020-11-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed gcloud || return 0
    koopa::h1 'Updating Google Cloud SDK.'
    if koopa::is_installed brew
    then
        koopa 'Homebrew is installed. Skipping manual update.'
    fi
    gcloud components update
    return 0
}
