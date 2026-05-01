#!/usr/bin/env bash

main() {
    # """
    # Install Apache Portable Runtime (APR) library.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/apr.rb
    # - macOS build issue:
    #  https://bz.apache.org/bugzilla/show_bug.cgi?id=64753
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://archive.apache.org/dist/apr/\
apr-${dict['version']}.tar.bz2"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
