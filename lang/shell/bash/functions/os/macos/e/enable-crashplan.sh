#!/usr/bin/env bash

koopa_macos_enable_crashplan() {
    # """
    # Enable CrashPlan.
    # @note Updated 2022-11-08.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.code42.menubar.plist" \
        '/Library/LaunchDaemons/com.code42.service.plist'
    return 0
}
