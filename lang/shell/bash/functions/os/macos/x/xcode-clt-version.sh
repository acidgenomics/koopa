#!/usr/bin/env bash

koopa_macos_xcode_clt_version() {
    # """
    # Xcode CLT version.
    # @note Updated 2023-04-05.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/180957
    # - pkgutil --pkgs=com.apple.pkg.Xcode
    # """
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['pkgutil']="$(koopa_macos_locate_pkgutil)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['pkgutil']}" --pkg-info='com.apple.pkg.CLTools_Executables' \
        | koopa_grep --pattern='^version:\s' --regex \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
