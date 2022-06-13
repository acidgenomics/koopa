#!/usr/bin/env bash

main() {
    # """
    # Install asdf.
    # @note Updated 2022-06-13.
    # """
    local dict
    declare -A dict=(
        [name]='asdf'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/asdf-vm/${dict[name]}/archive/refs/\
tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cp "${dict[name]}-${dict[version]}" "${dict[prefix]}"
    return 0
}
