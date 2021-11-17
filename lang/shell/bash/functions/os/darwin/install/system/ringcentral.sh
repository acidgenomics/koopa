#!/usr/bin/env bash

koopa::macos_uninstall_ringcentral() { # {{{1
    koopa::uninstall_app \
        --name-fancy='RingCentral' \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}

koopa:::macos_uninstall_ringcentral() { # {{{1
    # """
    # Uninstall RingCentral.
    # @note Updated 2021-10-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::rm --sudo \
        '/Applications/RingCentral Meetings.app'
    koopa::rm \
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
