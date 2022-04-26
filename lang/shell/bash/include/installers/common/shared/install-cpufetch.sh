#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install cpufetch.
    # @note Updated 2022-04-08.
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
    # The 'make install' step is currently problematic on macOS.
    # > PREFIX="${dict[prefix]}" "${app[make]}" install
    koopa_cp --target-directory="${dict[prefix]}/bin" 'cpufetch'
    koopa_cp --target-directory="${dict[prefix]}/man/man1" 'cpufetch.1'
    return 0
}
