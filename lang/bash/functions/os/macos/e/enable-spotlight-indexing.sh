#!/usr/bin/env bash

koopa_macos_enable_spotlight_indexing() {
    # """
    # Enable spotlight indexing.
    # @note Updated 2024-11-27.
    #
    # Conversely, use 'off' instead of 'on' to disable.
    #
    # Useful command to monitor mds usage:
    # > sudo fs_usage -w -f filesys mds
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['mdutil']="$(koopa_macos_locate_mdutil)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['mdutil']}" -a -i on
    "${app['mdutil']}" -a -s
    return 0
}
