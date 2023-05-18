#!/usr/bin/env bash

koopa_macos_disable_spotlight_indexing() {
    # """
    # Disable spotlight indexing.
    # @note Updated 2023-05-01.
    #
    # Conversely, use 'on' instead of 'off' to re-enable.
    #
    # Useful command to monitor mds usage:
    # > sudo fs_usage -w -f filesys mds
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['mdutil']="$(koopa_macos_locate_mdutil)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['mdutil']}" -a -i off
    "${app['mdutil']}" -a -s
    return 0
}
