#!/usr/bin/env bash

main() {
    # """
    # Install GMP.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/gmp.rb
    # - https://gmplib.org/manual/Build-Options
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'm4'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        '--enable-cxx'
        "--prefix=${dict['prefix']}"
        '--with-pic'
    )
    dict['url']="https://gmplib.org/download/gmp/gmp-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
