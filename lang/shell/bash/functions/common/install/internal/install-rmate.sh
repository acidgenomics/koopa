#!/usr/bin/env bash

koopa:::install_rmate() { # {{{1
    # """
    # Install rmate.
    # @note Updated 2022-01-24.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [name]='rmate'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/aurora/${dict[name]}/archive/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    koopa::chmod 'a+x' "${dict[name]}"
    koopa::cp --target-directory="${dict[prefix]}/bin" "${dict[name]}"
    return 0
}
