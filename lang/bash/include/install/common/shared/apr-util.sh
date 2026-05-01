#!/usr/bin/env bash

main() {
    # """
    # Install apr-util, companion library to apr.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     apr-util.rb
    # - https://bz.apache.org/bugzilla/show_bug.cgi?id=61379
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'apr' 'expat' 'openssl'
    dict['apr']="$(_koopa_app_prefix 'apr')"
    dict['expat']="$(_koopa_app_prefix 'expat')"
    dict['openssl']="$(_koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        "--with-apr=${dict['apr']}/bin/apr-1-config"
        '--with-crypto'
        "--with-expat=${dict['expat']}"
        "--with-openssl=${dict['openssl']}"
        '--without-pgsql'
        '--without-sqlite3'
    )
    dict['url']="https://archive.apache.org/dist/apr/\
apr-util-${dict['version']}.tar.bz2"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
