#!/usr/bin/env bash

koopa::macos_uninstall_onedrive() { # {{{1
    # """
    # Uninstall Microsoft OneDrive.
    # @note Updated 2020-07-20.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Microsoft OneDrive'
    koopa::uninstall_start "$name_fancy"
    koopa::rm \
        "${HOME}/Library/Containers/com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Application Scripts/\
com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Group Containers/UBF8T346G9.OneDriveSyncClientSuite"
    koopa::rm -S '/Applications/OneDrive.app'
    koopa::uninstall_success "$name_fancy"
    return 0
}

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
    koopa::rm -S \
        "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" \
        "/Library/LaunchAgents/com.oracle.java.Java-Updater.plist" \
        "/Library/LaunchDaemons/com.oracle.java.Helper-Tool.plist" \
        "/Library/PreferencePanes/JavaControlPanel.prefPane" \
        "/Library/Preferences/com.oracle.java.Helper-Tool.plist"
    koopa::uninstall_success "$name_fancy"
    return 0
}

koopa::macos_uninstall_ringcentral() { # {{{1
    # """
    # Uninstall RingCentral.
    # @note Updated 2020-07-20.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy="RingCentral"
    koopa::uninstall_start "$name_fancy"
    koopa::rm \
        "${HOME}/Library/Application Support/RingCentral Meetings" \
        "${HOME}/Library/Caches/us.zoom.ringcentral" \
        "${HOME}/Library/Internet Plug-Ins/RingCentralMeetings.plugin" \
        "${HOME}/Library/Internet Plug-Ins/RingCentralMeetings.plugin/\
Contents/MacOS/RingCentralMeetings" \
        "${HOME}/Library/Logs/RingCentralMeetings" \
        "${HOME}/Preferences/RingcentralChat.plist" \
        "${HOME}/Preferences/us.zoom.ringcentral.plist"
    koopa::rm -S "/Applications/RingCentral Meetings.app"
    koopa::uninstall_success "$name_fancy"
    return 0
}

koopa::macos_uninstall_webex() { # {{{1
    # """
    # Uninstall WebEx.
    # @note Updated 2020-07-20.
    # @seealso
    # - https://help.webex.com/en-us/WBX38280/
    #       How-Do-I-Uninstall-Webex-Software-on-a-Mac
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy="Webex"
    koopa::uninstall_start "$name_fancy"
    # Consider:
    # - ~/.Webex
    # - ~/Library/Application Support/Google/Chrome Canary/\
    #       NativeMessagingHosts/com.webex.meeting.json
    # - ~/Library/Application Support/Google/Chrome/NativeMessagingHosts/
    #       com.webex.meeting.json
    # - ~/Library/Application Support/Mozilla/NativeMessagingHosts/
    #       com.webex.meeting.json
    koopa::rm \
        "${HOME}/Library/Application Support/Cisco/WebEx Meetings" \
        "${HOME}/Library/Application Support/WebEx Folder" \
        "${HOME}/Library/Application Support/com.apple.sharedfilelist/\
    com.apple.LSSharedFileList.ApplicationRecentDocuments/"*'.webex.'*'.sfl' \
        "${HOME}/Library/Caches/com.cisco.webex"* \
        "${HOME}/Library/Caches/com.webex.meetingmanager" \
        "${HOME}/Library/Cookies/com.webex.meetingmanager.binarycookies" \
        "${HOME}/Library/Group Containers/group.com.cisco.webex.meetings" \
        "${HOME}/Library/Internet Plug-Ins/Webex.plugin" \
        "${HOME}/Library/Logs/WebexMeetings" \
        "${HOME}/Library/Logs/webexmta" \
        "${HOME}/Library/Preferences/"*'.webex.'*'.plist' \
        "${HOME}/Library/Receipts/"*'.webex.'* \
        "${HOME}/Library/Safari/LocalStorage/"*'.webex.com'* \
        "${HOME}/Library/WebKit/com.webex.meetingmanager"
    koopa::rm -S '/Applications/Cisco Webex Meetings.app'
    koopa::uninstall_success "$name_fancy"
    return 0
}
