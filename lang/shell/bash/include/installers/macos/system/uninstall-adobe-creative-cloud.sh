#!/usr/bin/env bash

main() {
    # """
    # Uninstall Adobe Creative Cloud preferences.
    # @note Updated 2021-10-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/Library/Application Support/Adobe'* \
        '/Library/Application Support/regid.'*'.com.adobe' \
        '/Library/Caches/com.'{a,A}'dobe'* \
        '/Library/Fonts/'{a,A}'dobe'* \
        '/Library/Preferences/com.'{a,A}'dobe'* \
        '/Library/ScriptingAdditions/Adobe Unit Types.osax' \
        '/Users/Shared/Adobe'
    koopa_rm \
        "${HOME}/Documents/Adobe" \
        "${HOME}/Library/Application Support/Adobe"* \
        "${HOME}/Library/Caches/Adobe"* \
        "${HOME}/Library/Caches/com.adobe"* \
        "${HOME}/Library/Preferences/Adobe"* \
        "${HOME}/Library/Preferences/ByHost/com.adobe"* \
        "${HOME}/Library/Preferences/Macromedia" \
        "${HOME}/Library/Preferences/com."{a,A}"dobe"* \
        "${HOME}/Library/Saved Application State/com."{a,A}"dobe"*
    return 0
}
