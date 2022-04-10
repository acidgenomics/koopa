#!/usr/bin/env bash

# FIXME This needs scons to be installed first.

main() { # {{{1
    # """
    # Install Apache Serf.
    # @note Updated 2022-04-09.
    #
    # Required by subversion for HTTPS connections.
    #
    # @seealso
    # - https://serf.apache.org/download
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='serf'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--with-serf' # Required for HTTPS URLs.
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://www.apache.org/dist/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}"
    "${app[make]}" install
    return 0
}
