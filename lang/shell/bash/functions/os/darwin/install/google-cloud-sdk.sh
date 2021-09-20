#!/usr/bin/env bash

koopa:::macos_update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2021-09-20.
    # """
    local brew
    koopa::assert_has_no_args "$#"
    brew="$(koopa::locate_brew)"
    "$brew" reinstall --cask 'google-cloud-sdk'
    return 0
}
