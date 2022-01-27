#!/usr/bin/env bash

koopa:::install_openssh() { # {{{1
    # """
    # Install OpenSSH.
    # @note Updated 2022-01-19.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='openssh'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
