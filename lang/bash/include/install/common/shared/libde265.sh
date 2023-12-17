#!/usr/bin/env bash

main() {
    # """
    # Install libde265.
    # @note Updated 2023-12-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libde265/
    # - https://ports.macports.org/port/libde265/
    # - https://github.com/strukturag/libde265/issues/284
    # """
    local -A dict
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-arm'
        '--disable-dec265'
        '--disable-dependency-tracking'
        '--disable-sherlock265'
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/strukturag/libde265/releases/download/\
v${dict['version']}/libde265-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
