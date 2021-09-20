#!/usr/bin/env bash

koopa::macos_uninstall_oracle_java() { # {{{1
    # """
    # Uninstall Oracle Java.
    # @note Updated 2020-07-17.
    # @seealso
    # - https://www.java.com/en/download/help/mac_uninstall_java.xml
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Oracle Java'
    koopa::uninstall_start "$name_fancy"
    koopa::rm \
        "${HOME}/Library/Caches/com.oracle.java.Java-Updater" \
        "${HOME}/Library/Application Support/Oracle/Java" \
        "${HOME}/Library/Preferences/com.apple.java.util.prefs.plist" \
        "${HOME}/Library/Preferences/com.oracle.java.JavaAppletPlugin.plist" \
        "${HOME}/Library/Safari/LocalStorage/https_www.java.com_0.localstorage"*
    koopa::rm --sudo \
        '/Library/Internet Plug-Ins/JavaAppletPlugin.plugin' \
        '/Library/LaunchAgents/com.oracle.java.Java-Updater.plist' \
        '/Library/LaunchDaemons/com.oracle.java.Helper-Tool.plist' \
        '/Library/PreferencePanes/JavaControlPanel.prefPane' \
        '/Library/Preferences/com.oracle.java.Helper-Tool.plist'
    koopa::uninstall_success "$name_fancy"
    return 0
}
