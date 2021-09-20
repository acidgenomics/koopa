#!/usr/bin/env bash

koopa::macos_uninstall_ringcentral() { # {{{1
    # """
    # Uninstall RingCentral.
    # @note Updated 2020-07-20.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='RingCentral'
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
    koopa::rm -S '/Applications/RingCentral Meetings.app'
    koopa::uninstall_success "$name_fancy"
    return 0
}
