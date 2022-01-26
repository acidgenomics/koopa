#!/usr/bin/env bash

koopa::macos_update_google_cloud_sdk() { # {{{1
    koopa::update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='macos' \
        --system \
        "$@"
}

koopa:::macos_update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2021-10-30.
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    "${app[brew]}" reinstall --cask 'google-cloud-sdk'
    return 0
}
