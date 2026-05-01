#!/usr/bin/env bash

_koopa_macos_app_version() {
    # """
    # Extract the version of a macOS application.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_macos_app_version 'BBEdit'
    # """
    local -A app
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['plutil']="$(_koopa_macos_locate_plutil)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for app in "$@"
    do
        local plist str
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
        # shellcheck disable=SC2016
        str="$( \
            "${app['plutil']}" -p "$plist" \
                | _koopa_grep --pattern='CFBundleShortVersionString' - \
                | "${app['awk']}" -F ' => ' '{print $2}' \
                | "${app['tr']}" --delete '\"' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}
