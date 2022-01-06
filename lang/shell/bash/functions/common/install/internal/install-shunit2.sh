#!/usr/bin/env bash

koopa:::install_shunit2() { # {{{1
    # """
    # Install shUnit2.
    # @note Updated 2022-01-06.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [name]='shunit2'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/kward/${dict[name]}/archive/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    koopa::cp --target-directory="${dict[prefix]}/bin" "${dict[name]}"
    return 0
}
