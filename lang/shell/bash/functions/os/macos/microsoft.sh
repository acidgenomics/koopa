#!/usr/bin/env bash

koopa::macos_update_microsoft_office() { # {{{1
    # """
    # Update Microsoft Office.
    # @note Updated 2020-07-21.
    # """
    local msupdate
    koopa::assert_has_no_args "$#"
    koopa::h1 "Updating Microsoft Office via 'msupdate'."
    msupdate="/Library/Application Support/Microsoft/MAU2.0/\
Microsoft AutoUpdate.app/Contents/MacOS/msupdate"
    "$msupdate" --install
    return 0
}

