#!/usr/bin/env bash

koopa::get_macos_app_version() { # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2021-05-21.
    # """
    local app awk grep plist tr x
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'plutil'
    awk="$(koopa::locate_awk)"
    grep="$(koopa::locate_grep)"
    tr="$(koopa::locate_tr)"
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
        # FIXME Rework using 'koopa::grep'.
        # shellcheck disable=SC2016
        x="$( \
            plutil -p "$plist" \
                | "$grep" 'CFBundleShortVersionString' \
                | "$awk" -F ' => ' '{print $2}' \
                | "$tr" -d '\"' \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_homebrew_cask_version() { # {{{1
    # """
    # Get Homebrew Cask version.
    # @note Updated 2021-05-06.
    #
    # @examples koopa::get_homebrew_cask_version gpg-suite
    # # 2019.2
    # """
    local cask x
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'brew'
    for cask in "$@"
    do
        x="$(brew info --cask "$cask")"
        x="$(koopa::extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}
