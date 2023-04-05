#!/usr/bin/env bash

koopa_macos_app_version() {
    # """
    # Extract the version of a macOS application.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_macos_app_version 'BBEdit'
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['plutil']="$(koopa_macos_locate_plutil)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for app in "$@"
    do
        local plist str
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
        # shellcheck disable=SC2016
        str="$( \
            "${app['plutil']}" -p "$plist" \
                | koopa_grep --pattern='CFBundleShortVersionString' - \
                | "${app['awk']}" -F ' => ' '{print $2}' \
                | "${app['tr']}" --delete '\"' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}
