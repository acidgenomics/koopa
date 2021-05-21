#!/usr/bin/env bash

koopa::get_macos_app_version() { # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2021-05-20.
    # """
    local app awk brew_prefix grep plist tr x
    koopa::assert_has_args "$#"
    awk='awk'
    grep='grep'
    tr='tr'
    if koopa::is_macos
    then
        # FIXME Use the opt locations here instead...
        brew_prefix="$(koopa::homebrew_prefix)"
        awk="${brew_prefix}/bin/gawk"
        grep="${brew_prefix}/bin/ggrep"
        tr="${brew_prefix}/bin/gtr"
    fi
    koopa::assert_is_gnu "$awk" "$grep" "$tr"
    koopa::assert_is_installed 'plutil'
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
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
