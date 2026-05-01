#!/usr/bin/env bash

_koopa_macos_disable_crashplan() {
    # """
    # Disable CrashPlan.
    # @note Updated 2022-11-08.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_macos_disable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.code42.menubar.plist" \
        '/Library/LaunchDaemons/com.code42.service.plist'
    return 0
}
