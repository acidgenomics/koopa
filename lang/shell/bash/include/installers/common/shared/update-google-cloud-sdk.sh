#!/usr/bin/env bash

main() {
    # """
    # Update Google Cloud SDK.
    # @note Updated 2022-04-06.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/components
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gcloud]="$(koopa_locate_gcloud)"
    )
    "${app[gcloud]}" --quiet components update
    return 0
}
