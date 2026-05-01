#!/usr/bin/env bash

main() {
    # """
    # Install isl.
    # @note Updated 2025-01-03.
    #
    # @seealso
    # - https://libisl.sourceforge.io/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/isl.rb
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'gmp'
    dict['gmp']="$(_koopa_app_prefix 'gmp')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
        '--with-gmp=system'
        "--with-gmp-prefix=${dict['gmp']}"
    )
    dict['url']="https://koopa.acidgenomics.com/src/isl/\
${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
