#!/bin/sh

koopa_duration_start() {
    # """
    # Start activation duration timer.
    # @note Updated 2022-04-10.
    # """
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    [ -x "${bin_prefix}/date" ] || return 0
    KOOPA_DURATION_START="$(date -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}
