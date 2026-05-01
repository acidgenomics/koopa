#!/usr/bin/env bash

_koopa_macos_enable_gpg_updater() {
    # """
    # Enable GPG tools updater.
    # @note Updated 2022-02-16.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}
