#!/usr/bin/env bash

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
    name_fancy='Webex'
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
    koopa::rm --sudo '/Applications/Cisco Webex Meetings.app'
    koopa::uninstall_success "$name_fancy"
    return 0
}
