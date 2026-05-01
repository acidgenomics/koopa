#!/usr/bin/env bash

main() {
    # """
    # Install FLAC.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://xiph.org/flac/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/flac.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/multimedia/flac.html
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-thorough-tests'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://downloads.xiph.org/releases/flac/\
flac-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
