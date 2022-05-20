#!/usr/bin/env bash

koopa_macos_app_version() {
    # """
    # Extract the version of a macOS application.
    # @note Updated 2022-05-19.
    #
    # @examples
    # > koopa_macos_app_version 'BBEdit'
    # """
    local app x
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [plutil]="$(koopa_macos_locate_plutil)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[plutil]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
        # shellcheck disable=SC2016
        x="$( \
            "${app[plutil]}" -p "$plist" \
                | koopa_grep --pattern='CFBundleShortVersionString' - \
                | "${app[awk]}" -F ' => ' '{print $2}' \
                | "${app[tr]}" --delete '\"' \
        )"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}
