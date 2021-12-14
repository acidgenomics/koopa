#!/usr/bin/env bash

koopa:::install_neofetch() { # {{{1
    # """
    # Install neofetch.
    # @note Updated 2021-12-14.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [name]='neofetch'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/dylanaraps/${dict[name]}/\
archive/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    koopa::mkdir "${dict[prefix]}"
    "${app[make]}" PREFIX="${dict[prefix]}" install
    return 0
}
