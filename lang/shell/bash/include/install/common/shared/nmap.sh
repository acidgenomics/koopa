#!/usr/bin/env bash

main() {
    # """
    # Install nmap.
    # @note Updated 2022-08-27.
    # 
    # @seealso
    # - https://nmap.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nmap.rb
    # - Check supported Lua version at:
    #   https://github.com/nmap/nmap/tree/master/liblua
    # """
    local app conf_args dict
    koopa_activate_build_opt_prefix \
        'bison' \
        'flex'
    koopa_activate_opt_prefix \
        'zlib' \
        'openssl3' \
        'libssh2' \
        'pcre' \
        'lua'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['lua']="$(koopa_app_prefix 'lua')"
        ['name']='nmap'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['pcre']="$(koopa_app_prefix 'pcre')"
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://nmap.org/dist/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-universal'
        "--with-liblua=${dict['lua']}"
        "--with-libpcre=${dict['pcre']}"
        "--with-openssl=${dict['openssl']}"
        '--without-nmap-update'
        '--without-zenmap'
    )
    ./configure "${conf_args[@]}"
    "${app['make']}"
    "${app['make']}" install
    return 0
}
