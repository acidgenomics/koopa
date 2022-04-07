#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Oracle Java.
    # @note Updated 2021-10-30.
    # @seealso
    # - https://www.java.com/en/download/help/mac_uninstall_java.xml
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/Library/Internet Plug-Ins/JavaAppletPlugin.plugin' \
        '/Library/LaunchAgents/com.oracle.java.Java-Updater.plist' \
        '/Library/LaunchDaemons/com.oracle.java.Helper-Tool.plist' \
        '/Library/PreferencePanes/JavaControlPanel.prefPane' \
        '/Library/Preferences/com.oracle.java.Helper-Tool.plist'
    koopa_rm \
        "${HOME}/Library/Caches/com.oracle.java.Java-Updater" \
        "${HOME}/Library/Application Support/Oracle/Java" \
        "${HOME}/Library/Preferences/com.apple.java.util.prefs.plist" \
        "${HOME}/Library/Preferences/com.oracle.java.JavaAppletPlugin.plist" \
        "${HOME}/Library/Safari/LocalStorage/https_www.java.com_0.localstorage"*
    return 0
}
