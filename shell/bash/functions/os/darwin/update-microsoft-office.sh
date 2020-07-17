#!/usr/bin/env bash

koopa::macos_update_microsoft_office() { # {{{1
    # """
    # Update Microsoft Office.
    # @note Updated 2020-07-17.
    # """
    local update_exe
    koopa::assert_has_no_args "$#"
    koopa::h1 'Updating Microsoft Office via "msupdate".'
    update_exe="/Library/Application Support/Microsoft/MAU2.0/\
Microsoft AutoUpdate.app/Contents/MacOS/msupdate"
    "$update_exe" --install
    return 0
}

