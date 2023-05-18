#!/usr/bin/env bash

main() {
    # """
    # Install jemalloc.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     jemalloc.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-static'
        "--prefix=${dict['prefix']}"
        '--with-jemalloc-prefix='
    )
    dict['url']="https://github.com/jemalloc/jemalloc/releases/download/\
${dict['version']}/jemalloc-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
