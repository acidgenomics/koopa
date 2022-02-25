#!/usr/bin/env bash

macos_update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2021-10-30.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    "${app[brew]}" reinstall --cask 'google-cloud-sdk'
    return 0
}
