#!/usr/bin/env bash

koopa::update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2020-07-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed gcloud || return 0
    koopa::h1 'Updating Google Cloud SDK.'
    gcloud components update
    return 0
}
