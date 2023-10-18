#!/usr/bin/env bash

# FIXME Build is currently erroring out without much info on macOS.

main() {
    # """
    # Install nmap.
    # @note Updated 2023-04-10.
    #
    # May need to include libcap and liblinear here.
    #
    # @seealso
    # - https://nmap.org/
    # - https://svn.nmap.org/nmap/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nmap.rb
    # - https://git.alpinelinux.org/aports/tree/main/nmap/APKBUILD
    # - Check supported Lua version at:
    #   https://github.com/nmap/nmap/tree/master/liblua
    # """
    local -A dict
    local -a conf_args deps
    koopa_activate_app --build-only 'bison' 'flex'
    deps=('zlib' 'openssl3' 'pcre')
    koopa_activate_app "${deps[@]}"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['pcre']="$(koopa_app_prefix 'pcre')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-libdnet=included'
        '--with-liblinear=included'
        '--with-liblua=included'
        "--with-libpcre=${dict['pcre']}"
        '--with-libpcre=included'
        '--with-libssh2=included'
        "--with-libz=${dict['zlib']}"
        "--with-openssl=${dict['openssl']}"
        '--without-zenmap'
    )
    dict['url']="https://nmap.org/dist/nmap-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
