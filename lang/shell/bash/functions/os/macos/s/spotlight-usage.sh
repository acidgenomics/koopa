#!/usr/bin/env bash

koopa_macos_spotlight_usage() {
    # """
    # Monitor current spotlight indexing usage.
    # @note Updated 2023-04-05.
    #
    # Useful for debugging out of control mds_stores that makes my laptop
    # sound like a jet engine.
    # """
    local -A app
    app['fs_usage']="$(koopa_macos_locate_fs_usage)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    "${app['sudo']}" "${app['fs_usage']}" -w -f filesys mds
    return 0
}
