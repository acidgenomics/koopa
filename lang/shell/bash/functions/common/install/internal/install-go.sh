#!/usr/bin/env bash

koopa:::install_go() { # {{{1
    # """
    # Install Go.
    # @note Updated 2021-11-23.
    # """
    local dict
    declare -A dict=(
        [arch]="$(koopa::arch2)"  # e.g. "amd64".
        [name]='go'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa::is_macos
    then
        dict[os_id]='darwin'
    else
        dict[os_id]='linux'
    fi
    dict[file]="${dict[name]}${dict[version]}.${dict[os_id]}-\
${dict[arch]}.tar.gz"
    dict[url]="https://dl.google.com/${dict[name]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cp --target-directory="${dict[prefix]}" "${dict[name]}/"*
    return 0
}
