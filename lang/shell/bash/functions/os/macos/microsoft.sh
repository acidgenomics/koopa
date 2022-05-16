#!/usr/bin/env bash

koopa_macos_update_microsoft_office() {
    # """
    # Update Microsoft Office.
    # @note Updated 2020-07-21.
    # """
    local msupdate
    koopa_assert_has_no_args "$#"
    koopa_h1 "Updating Microsoft Office via 'msupdate'."
    msupdate="/Library/Application Support/Microsoft/MAU2.0/\
Microsoft AutoUpdate.app/Contents/MacOS/msupdate"
    "$msupdate" --install
    return 0
}

