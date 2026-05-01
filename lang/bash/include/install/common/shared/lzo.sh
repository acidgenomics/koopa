#!/usr/bin/env bash

main() {
    # """
    # Install lzo.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/lzo.rb
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-static'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://www.oberhumer.com/opensource/lzo/\
download/lzo-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
