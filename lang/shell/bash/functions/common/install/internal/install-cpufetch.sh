#!/usr/bin/env bash

koopa:::install_cpufetch() { # {{{1
    # """
    # Install cpufetch.
    # @note Updated 2021-12-01.
    # """
    local app dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='cpufetch'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/Dr-Noob/${dict[name]}/archive/refs/\
tags/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    # Installer doesn't currently support 'configure' script.
    PREFIX="${dict[prefix]}" "${app[make]}" --jobs="${dict[jobs]}"
    PREFIX="${dict[prefix]}" "${app[make]}" install
    return 0
}
