#!/usr/bin/env bash

main() {
    # """
    # Install libevent.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #       Formula/libevent.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'openssl'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug-mode'
        '--disable-dependency-tracking'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/libevent/libevent/releases/download/\
release-${dict['version']}-stable/libevent-${dict['version']}-stable.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
