#!/usr/bin/env bash

main() {
    # """
    # Install SoX.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/sox.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'flac'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://downloads.sourceforge.net/project/sox/sox/\
${dict['version']}/sox-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
