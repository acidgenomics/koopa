#!/usr/bin/env bash

main() {
    # """
    # Install samtools.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/samtools/samtools/
    # """
    local -A dict
    local -a conf_args
    deps=(
        'xz'
        'zlib'
        'ncurses'
        'htslib'
    )
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-htslib=system'
    )
    dict['url']="https://github.com/samtools/samtools/releases/download/\
${dict['version']}/samtools-${dict['version']}.tar.bz2"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
