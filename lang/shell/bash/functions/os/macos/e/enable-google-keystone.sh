#!/usr/bin/env bash

koopa_macos_enable_google_keystone() {
    # """
    # Enable Google Keystone.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/com.google.keystone.agent.plist' \
        '/Library/LaunchAgents/com.google.keystone.xpcservice.plist' \
        '/Library/LaunchDaemons/com.google.keystone.daemon.plist'
    return 0
}
