#!/usr/bin/env bash

koopa_df() {
    # """
    # Human friendly version of GNU df.
    # @note Updated 2021-10-29.
    # """
    local app
    declare -A app=(
        [df]="$(koopa_locate_df)"
    )
    "${app[df]}" \
        --portability \
        --print-type \
        --si \
        "$@"
    return 0
}
