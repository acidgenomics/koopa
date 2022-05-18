#!/usr/bin/env bash

koopa_macos_enable_crashplan() {
    # """
    # Enable CrashPlan.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.crashplan.engine.plist" \
        '/Library/LaunchDaemons/com.crashplan.engine.plist'
    return 0
}
