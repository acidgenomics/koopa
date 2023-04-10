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
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'm4'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--enable-cxx'
        "--prefix=${dict['prefix']}"
        '--with-pic'
    )
    dict['url']="https://gmplib.org/download/gmp/gmp-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
