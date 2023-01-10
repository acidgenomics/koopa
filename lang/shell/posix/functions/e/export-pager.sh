#!/bin/sh

koopa_export_pager() {
    # """
    # Export 'PAGER' variable.
    # @note Updated 2022-05-12.
    #
    # @seealso
    # - 'tldr --pager' (Rust tealdeer) requires the '-R' flag to be set here,
    #   otherwise will return without proper escape code handling.
    # """
    local less
    [ -n "${PAGER:-}" ] && return 0
    less="$(koopa_bin_prefix)/less"
    [ -x "$less" ] || return 0
    export PAGER="${less} -R"
    return 0
}
