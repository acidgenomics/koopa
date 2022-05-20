#!/usr/bin/env bash

koopa_macos_xcode_clt_version() {
    # """
    # Xcode CLT version.
    # @note Updated 2022-05-19.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [pkgutil]="$(koopa_macos_locate_pkgutil)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[pkgutil]}" ]] || return 1
    str="$( \
        "${app[pkgutil]}" --pkg-info='com.apple.pkg.CLTools_Executables' \
        | koopa_grep --pattern='^version:\s' --regex \
        | "${app[cut]}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
