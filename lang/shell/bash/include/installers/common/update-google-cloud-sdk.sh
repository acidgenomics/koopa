#!/usr/bin/env bash

update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2022-04-04.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gcloud]="$(koopa_locate_gcloud)"
    )
    "${app[gcloud]}" components update
    return 0
}
