#!/usr/bin/env bash

koopa_macos_spotlight_usage() {
    # """
    # Monitor current spotlight indexing usage.
    # @note Updated 2023-05-01.
    #
    # Useful for debugging out of control mds_stores that makes my laptop
    # sound like a jet engine.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['fs_usage']="$(koopa_macos_locate_fs_usage)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['fs_usage']}" -w -f filesys mds
    return 0
}
