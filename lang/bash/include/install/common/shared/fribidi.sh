#!/usr/bin/env bash

main() {
    # """
    # Install fribidi.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/fribidi/fribidi
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/fribidi.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/fribidi/fribidi/releases/download/\
v${dict['version']}/fribidi-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
