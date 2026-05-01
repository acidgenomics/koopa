#!/usr/bin/env bash

main() {
    # """
    # Install libpng.
    # @note Updated 2025-01-03.
    #
    # @seealso
    # - http://www.libpng.org/pub/png/libpng.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libpng.rb
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app 'pkg-config'
    _koopa_activate_app 'zlib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-shared=yes'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://koopa.acidgenomics.com/src/libpng/\
${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
