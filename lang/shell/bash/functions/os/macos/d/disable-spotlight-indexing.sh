#!/usr/bin/env bash

koopa_macos_disable_spotlight_indexing() {
    # """
    # Disable spotlight indexing.
    # @note Updated 2023-04-05.
    #
    # Conversely, use 'on' instead of 'off' to re-enable.
    #
    # Useful command to monitor mds usage:
    # > sudo fs_usage -w -f filesys mds
    # """
    local -A app
    app['mdutil']="$(koopa_macos_locate_mdutil)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    "${app['sudo']}" "${app['mdutil']}" -a -i off
    "${app['mdutil']}" -a -s
    return 0
}
