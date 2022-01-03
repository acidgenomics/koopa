#!/usr/bin/env bash

koopa:::install_udunits() { # {{{1
    # """
    # Install udunits.
    # @note Updated 2022-01-03.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='udunits'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    # HTTP alternative:
    # > dict[url]="https://www.unidata.ucar.edu/downloads/
    # >     ${dict[name]}/${dict[file]}"
    dict[url]="ftp://ftp.unidata.ucar.edu/pub/${dict[name]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}
