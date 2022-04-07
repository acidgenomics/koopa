#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install cpufetch.
    # @note Updated 2021-12-01.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='cpufetch'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/Dr-Noob/${dict[name]}/archive/refs/\
tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # Installer doesn't currently support 'configure' script.
    PREFIX="${dict[prefix]}" "${app[make]}" --jobs="${dict[jobs]}"
    PREFIX="${dict[prefix]}" "${app[make]}" install
    return 0
}
