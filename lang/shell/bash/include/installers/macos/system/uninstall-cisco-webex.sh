#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Cisco WebEx.
    # @note Updated 2021-10-30.
    #
    # Consider removing:
    # - ~/.Webex
    # - ~/Library/Application Support/Google/Chrome Canary/\
    #       NativeMessagingHosts/com.webex.meeting.json
    # - ~/Library/Application Support/Google/Chrome/NativeMessagingHosts/
    #       com.webex.meeting.json
    # - ~/Library/Application Support/Mozilla/NativeMessagingHosts/
    #       com.webex.meeting.json
    #
    # @seealso
    # - https://help.webex.com/en-us/WBX38280/
    #       How-Do-I-Uninstall-Webex-Software-on-a-Mac
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_rm --sudo \
        '/Applications/Cisco Webex Meetings.app'
    koopa_rm \
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
    return 0
}
