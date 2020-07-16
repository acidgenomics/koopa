#!/usr/bin/env bash

koopa::update_google_cloud_sdk() {
    # """
    # Update Google Cloud SDK.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::exit_if_not_installed gcloud
    koopa::h1 'Updating Google Cloud SDK.'
    gcloud components update
    return 0
}
