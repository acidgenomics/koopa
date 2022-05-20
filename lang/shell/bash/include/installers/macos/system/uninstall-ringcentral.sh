#!/usr/bin/env bash

main() {
    # """
    # Uninstall RingCentral.
    # @note Updated 2021-10-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/Applications/RingCentral Meetings.app'
    koopa_rm \
        "${HOME}/Library/Application Support/RingCentral Meetings" \
        "${HOME}/Library/Caches/us.zoom.ringcentral" \
        "${HOME}/Library/Internet Plug-Ins/RingCentralMeetings.plugin" \
        "${HOME}/Library/Internet Plug-Ins/RingCentralMeetings.plugin/\
Contents/MacOS/RingCentralMeetings" \
        "${HOME}/Library/Logs/RingCentralMeetings" \
        "${HOME}/Preferences/RingcentralChat.plist" \
        "${HOME}/Preferences/us.zoom.ringcentral.plist"
    return 0
}
