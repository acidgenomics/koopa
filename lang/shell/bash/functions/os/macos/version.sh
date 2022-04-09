#!/usr/bin/env bash

koopa_get_macos_app_version() { # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2021-10-27.
    # """
    local app x
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [plutil]="$(koopa_macos_locate_plutil)"
        [tr]="$(koopa_locate_tr)"
    )
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

koopa_get_homebrew_cask_version() { # {{{1
    # """
    # Get Homebrew Cask version.
    # @note Updated 2021-10-27.
    #
    # @examples
    # > koopa_get_homebrew_cask_version 'gpg-suite'
    # # 2019.2
    # """
    local app cask x
    koopa_assert_has_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    for cask in "$@"
    do
        x="$("${app[brew]}" info --cask "$cask")"
        x="$(koopa_extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_macos_xcode_clt_version() { # {{{1
    # """
    # Xcode CLT version.
    # @note Updated 2022-04-09.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [pkgutil]="$(koopa_macos_locate_pkgutil)"
    )
    str="$( \
        "${app[pkgutil]}" --pkg-info='com.apple.pkg.CLTools_Executables' \
        | koopa_grep --pattern='^version:\s' --regex \
        | "${app[cut]}" --delim=' ' --fields='2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
