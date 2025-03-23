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
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'gmp'
    dict['gmp']="$(koopa_app_prefix 'gmp')"
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
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
