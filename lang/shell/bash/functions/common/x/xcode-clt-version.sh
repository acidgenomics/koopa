#!/usr/bin/env bash

koopa_xcode_clt_version() {
    # """
    # Xcode CLT version.
    # @note Updated 2022-02-27.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/180957
    # - pkgutil --pkgs=com.apple.pkg.Xcode
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_is_xcode_clt_installed || return 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [pkgutil]="$(koopa_macos_locate_pkgutil)"
    )
    declare -A dict=(
        [pkg]='com.apple.pkg.CLTools_Executables'
    )
    "${app[pkgutil]}" --pkgs="${dict[pkg]}" >/dev/null || return 1
    # shellcheck disable=SC2016
    dict[str]="$( \
        "${app[pkgutil]}" --pkg-info="${dict[pkg]}" \
            | "${app[awk]}" '/version:/ {print $2}' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
