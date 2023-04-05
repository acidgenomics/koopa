#!/usr/bin/env bash

koopa_macos_spotlight_usage() {
    # """
    # Monitor current spotlight indexing usage.
    # @note Updated 2022-02-28.
    #
    # Useful for debugging out of control mds_stores that makes my laptop
    # sound like a jet engine.
    # """
    local -A app=(
        ['fs_usage']="$(koopa_macos_locate_fs_usage)"
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['fs_usage']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    "${app['sudo']}" "${app['fs_usage']}" -w -f filesys mds
    return 0
}
