#!/usr/bin/env bash

_koopa_df() {
    # """
    # Human friendly version of GNU df.
    # @note Updated 2021-10-29.
    # """
    local -A app
    app['df']="$(_koopa_locate_df)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['df']}" \
        --portability \
        --print-type \
        --si \
        "$@"
    return 0
}
