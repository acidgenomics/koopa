#!/usr/bin/env bash

koopa::macos_delete_adobe_creative_cloud_preferences() { # {{{1
    # """
    # Delete Adobe Creative Cloud preferences.
    # @note Updated 2020-11-12.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    name_fancy='Adobe Creative Cloud preferences'
    koopa::uninstall_start "$name_fancy"
    koopa::rm \
        "${HOME}/Documents/Adobe" \
        "${HOME}/Library/Application Support/Adobe"* \
        "${HOME}/Library/Caches/Adobe"* \
        "${HOME}/Library/Caches/com.adobe"* \
        "${HOME}/Library/Preferences/Adobe"* \
        "${HOME}/Library/Preferences/ByHost/com.adobe"* \
        "${HOME}/Library/Preferences/Macromedia" \
        "${HOME}/Library/Preferences/com."{a,A}"dobe"* \
        "${HOME}/Library/Saved Application State/com."{a,A}"dobe"*
    koopa::rm -S \
        '/Library/Application Support/Adobe'* \
        '/Library/Application Support/regid.'*'.com.adobe' \
        '/Library/Caches/com.'{a,A}'dobe'* \
        '/Library/Fonts/'{a,A}'dobe'* \
        '/Library/Preferences/com.'{a,A}'dobe'* \
        '/Library/ScriptingAdditions/Adobe Unit Types.osax' \
        '/Users/Shared/Adobe'
    koopa::uninstall_success "$name_fancy"
    return 0
}
