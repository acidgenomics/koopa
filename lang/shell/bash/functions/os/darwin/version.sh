#!/usr/bin/env bash

koopa::get_macos_app_version() { # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2020-08-06.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed plutil
    local app plist x
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        if [[ ! -f "$plist" ]]
        then
            koopa::stop "'${app}' is not installed."
        fi
        x="$( \
            plutil -p "$plist" \
                | grep 'CFBundleShortVersionString' \
                | awk -F ' => ' '{print $2}' \
                | tr -d '\"' \
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
    koopa::assert_has_args "$#"
    koopa::is_installed brew || return 1
    local cask x
    for cask in "$@"
    do
        x="$(brew info --cask "$cask")"
        x="$(koopa::extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}
