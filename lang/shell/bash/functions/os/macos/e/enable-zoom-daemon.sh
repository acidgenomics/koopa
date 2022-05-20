#!/usr/bin/env bash

koopa_macos_enable_zoom_daemon() {
    # """
    # Enable Zoom daemon.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist'
    koopa_macos_enable_privileged_helper_tool \
        'us.zoom.ZoomDaemon'
}
