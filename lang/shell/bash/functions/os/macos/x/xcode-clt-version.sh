#!/usr/bin/env bash

koopa_macos_xcode_clt_version() {
    # """
    # Xcode CLT version.
    # @note Updated 2022-10-11.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/180957
    # - pkgutil --pkgs=com.apple.pkg.Xcode
    # """
    local app str
    koopa_assert_has_no_args "$#"
    local -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['pkgutil']="$(koopa_macos_locate_pkgutil)"
    )
    [[ -x "${app['cut']}" ]] || exit 1
    [[ -x "${app['pkgutil']}" ]] || exit 1
    str="$( \
        "${app['pkgutil']}" --pkg-info='com.apple.pkg.CLTools_Executables' \
        | koopa_grep --pattern='^version:\s' --regex \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
