#!/usr/bin/env bash

koopa_df() {
    # """
    # Human friendly version of GNU df.
    # @note Updated 2021-10-29.
    # """
    local app
    local -A app
    app['df']="$(koopa_locate_df)"
    [[ -x "${app['df']}" ]] || exit 1
    "${app['df']}" \
        --portability \
        --print-type \
        --si \
        "$@"
    return 0
}
