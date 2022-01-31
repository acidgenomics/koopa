#!/usr/bin/env bash

koopa:::debian_install_pandoc() { # {{{1
    # """
    # Install Pandoc.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [dpkg]="$(koopa::debian_locate_dpkg)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch2)"
        [version]="${INSTALL_VERSION:?}"
        [name]='pandoc'
    )
    dict[file]="${dict[name]}-${dict[version]}-1-${dict[arch]}.deb"
    dict[url]="https://github.com/jgm/${dict[name]}/releases/download/\
${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    "${app[sudo]}" "${app[dpkg]}" -i "${dict[file]}"
    return 0
}
