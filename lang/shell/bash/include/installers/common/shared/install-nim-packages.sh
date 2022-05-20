#!/usr/bin/env bash

main() {
    # """
    # Install Nim packages using nimble.
    # @note Updated 2022-03-29.
    #
    # @seealso
    # - https://github.com/nim-lang/nimble/issues/734
    # """
    local app i pkgs
    koopa_assert_has_no_args "$#"
    koopa_activate_nim
    declare -A app=(
        [nim]="$(koopa_locate_nim)"
        [nimble]="$(koopa_locate_nimble)"
    )
    pkgs=(
        'markdown'
    )
    for i in "${!pkgs[@]}"
    do
        local pkg pkg_lower version
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa_lowercase "$pkg")"
        version="$(koopa_variable "nim-${pkg_lower}")"
        pkgs[$i]="${pkg}@${version}"
    done
    "${app[nimble]}" \
        --accept \
        --nim:"${app[nim]}" \
        install "${pkgs[@]}"
    return 0
}
