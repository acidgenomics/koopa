#!/usr/bin/env bash

koopa::get_macos_app_version() { # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2021-10-27.
    # """
    local app x
    koopa::assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [plutil]="$(koopa::macos_locate_plutil)"
        [tr]="$(koopa::locate_tr)"
    )
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
        # shellcheck disable=SC2016
        x="$( \
            "${app[plutil]}" -p "$plist" \
                | koopa::grep 'CFBundleShortVersionString' \
                | "${app[awk]}" -F ' => ' '{print $2}' \
                | "${app[tr]}" -d '\"' \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_homebrew_cask_version() { # {{{1
    # """
    # Get Homebrew Cask version.
    # @note Updated 2021-10-27.
    #
    # @examples koopa::get_homebrew_cask_version gpg-suite
    # # 2019.2
    # """
    local app cask x
    koopa::assert_has_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    for cask in "$@"
    do
        x="$("${app[brew]}" info --cask "$cask")"
        x="$(koopa::extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}
